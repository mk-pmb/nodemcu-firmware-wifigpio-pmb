-- -*- coding: UTF-8, tab-width: 2 -*-

dofile('../mcuStubs.lua')
local test = require('qs/libTestUtil')
local meq = test.multi('eq')

local libKnecht = require('qs/libDavidKnecht')

local function createFakeHttpServer()
  return { serverIsFake=true }
end

local kn, job, rt
kn = libKnecht.spawn({createHttpServer=createFakeHttpServer})

rt = {
  GET='sendFile',
  ['/']={ GET='webRoot' },
  ['/favicon.ico']='randomFavi',
  ['*']=405,
  ['/upload']='dirRedir',
  ['/upload/']={
    GET=403,
    PUT='recvFile',
  },
}
kn.routesDict = rt

meq({kn:lookupHandler(nil, 'GET',   '/')},
  {'webRoot',         rt['/'],      '/', ''})

meq({kn:lookupHandler(nil, 'GET',   '/favicon.ico')},
  {'randomFavi',      rt,           '/favicon.ico', ''})

meq({kn:lookupHandler(nil, 'GET',   '/robots.txt')},
  {'sendFile',        rt,   '',     '/robots.txt'})

meq({kn:lookupHandler(nil, 'GET',   '/upload')},
  {'dirRedir',        rt,           '/upload', ''})

meq({kn:lookupHandler(nil, 'GET',   '/upload/secret.txt')},
  {403,         rt['/upload/'],     '/upload/', '/secret.txt'})

meq({kn:lookupHandler(nil, 'PUT',   '/upload/secret.txt')},
  {'recvFile',  rt['/upload/'],     '/upload/', '/secret.txt'})











print('+OK test passed')
