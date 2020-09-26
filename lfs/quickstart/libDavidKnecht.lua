-- -*- coding: UTF-8, tab-width: 2 -*-
--[[--------------------------------------------------------------------
A library to provide a minimalist WebDAV server. The library name is a
pun, and is not meant to refer to any current, past, or future, living
or dead, real or fictional, person named David Knecht.
--------------------------------------------------------------------]]--

local modName = ...
local modPfx = modName:match('^.+[%.%/]') or ''

local tabu = require(modPfx .. 'libTableUtil')
local KN, JM

JM = tabu.fallbackTable()
KN = tabu.fallbackTable({
  apiVersion = 2009260325,
  jobMeta = JM,
})


function KN.log(kn, msg, ...)
  print('[knecht:' .. tostring(kn.port or '(no port?!)') .. '] ' .. msg, ...)
end


function KN.spawn(cfg)
  cfg = cfg or {}
  local kn = setmetatable({
    cfg = cfg,
    routesDict = (cfg.routesDict or {}),
  }, KN)
  local port = (cfg.port or 80)
  kn.srv = (cfg.createHttpServer or require('httpserver').createServer
    )(port, function (...) return kn:jobify(...) end)
  kn.port = port
  return kn
end


function KN.jobify(kn, req, rsp)
  local job = setmetatable({
    kn = kn,
    req = req,
    rsp = rsp,
    verb = req.method,
    routedUrl = '',
    routesDict = nil,
    subUrl = req.url,
  }, kn.jobMeta)
  return kn.handle(job)
end


function KN.simpleHtmlMsg(msg, detail)
  return ([[
    <!DOCTYPE html><html><head>
    <meta charset="UTF-8">
      <title>]] .. msg .. [[</title>
    </head><body>
      <h2>]] .. msg .. [[</h2>
      <p>]] .. (detail or '') .. [[</p>
    </body></html>]])
end


function KN.handle(job)
  local subUrl = (job.subUrl or '')
  if (subUrl:sub(1, 1) ~= '/') then return nil end
  local pos = subUrl:match('()%?')
  if pos then
    job.rawQuery = subUrl:sub(pos + 1)
    subUrl = subUrl:sub(0, pos - 1)
    job.subUrl = subUrl
  end
  local kn = job.kn
  kn:log(('%q %q ?%q | M:%0.2fk'):format(job.verb, subUrl,
    (job.rawQuery or ''), (node.heap() / 1024)))
  local hndSpec
  hndSpec, job.routedUrl, job.subUrl = kn:lookupHandler(job.routesDict,
    job.verb, subUrl)
  kn:wrap500(hndSpec, job)
end


function KN.errUnsuppUrl(job)
  job.rsp:finish(KN.simpleHtmlMsg('Not implemented.'), 501 )
end


function KN.wrap500(kn, hndSpec, job)
  local ok, err = pcall((hndSpec or kn.errUnsuppUrl), job)
  if ok then return end
  kn:log(('%q %q..%q ?%q internal error:'):format(
    tostring(job.verb or '¿'),
    tostring(job.routedUrl or '¿'),
    tostring(job.subUrl or '¿'),
    tostring(job.rawQuery or '¿')
    ), err)
  job.rsp:finish(KN.simpleHtmlMsg('Internal Error.'), 500)
end


function KN.lookupHandler(kn, routesDict, verb, subUrl)
  -- returns: hndFunc, deepestRroutesDict, routedUrl, subUrl
  local rDict = (routesDict or kn.routesDict)
  local bestHnd
  local routedUrl = ''
  -- ^-- may differ from routedUrl:len() due to merged slashes
  ;(function ()
    local nxSub, nxUpto, nxPeek
    local nxHow, nxType
    while true do
      --[[--
        NB: Empty subUrl is no reason to skip, because we still have to
            check for the verb handler.
      --]]--
      if not rDict then return end
      bestHnd = (rDict[verb] or rDict['*'] or bestHnd)
      nxSub, nxUpto = subUrl:match('^/*(/[^/]*)()')
      nxUpto = (nxUpto or 0)
      nxPeek = subUrl:sub(nxUpto, nxUpto)
      if not nxSub then return end
      if nxPeek == '' then
        nxPeek = ''
      elseif nxPeek == '/' then
        nxSub = nxSub .. nxPeek
      else
        error(('Unexpected peek character: %q'):format(nxPeek))
      end
      nxHow = rDict[nxSub]
      if not nxHow then return end
      routedUrl = routedUrl .. nxSub
      subUrl = subUrl:sub(nxUpto)
      subUrlStart = nxUpto
      nxType = type(nxHow)
      if nxType == 'table' then
        rDict = nxHow
      else
        bestHnd = nxHow
        return
      end
    end
  end)()
  return bestHnd, rDict, routedUrl, subUrl
end











return KN
