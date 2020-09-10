-- -*- coding: UTF-8, tab-width: 2 -*-

local modName = ...
local modPfx = modName:match('^.+[%.%/]') or ''

local tabu = require(modPfx .. 'libTableUtil')

local cr = {}

local T = {
  criteria = cr,
}

function T.quot(x)
  local t = type(x)
  if t == 'string' then return ('%q'):format(x) end
  return tostring(x)
end


function T.failNamedCond(name, ac, ex, prop)
  prop = (prop or 'value')
  local msg = ('Actual %s %s not %s expected %s %s'
    ):format(prop, T.quot(ac), name, prop, T.quot(ex))
  error(msg)
end


function T.multi(condName)
  local chk = assert(cr[condName])
  return function (lac, lex)
    local nac = #lac
    local nex = #lex
    if nac < nex then
      error(('Too few actual results (%s < %s)'):format(nac, nex))
    elseif nac > nex then
      error(('Too many actual results (%s > %s)'):format(nac, nex))
    end
    local vac
    for k, vex in pairs(lex) do
      vac = lac[k]
      if not chk(vac, vex) then
        T.failNamedCond(condName, vac, vex, 'value ' .. tostring(k))
      end
    end
  end
end


function cr.eq(ac, ex) return (ac == ex) end





for cond, chk in pairs(cr) do
  T[cond] = function (ac, ex)
    return chk(ac, ex) or T.failNamedCond(cond, ac, ex)
  end
end


return T
