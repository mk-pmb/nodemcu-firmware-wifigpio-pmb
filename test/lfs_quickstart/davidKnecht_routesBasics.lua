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

meq({kn:lookupRoute(nil,  'GET',  '/')},
  {'webRoot',         rt['/'],    '/', ''})

meq({kn:lookupRoute(nil,  'GET',  '/favicon.ico')},
  {'randomFavi',      rt,         '/favicon.ico', ''})

meq({kn:lookupRoute(nil,  'GET',  '/robots.txt')},
  {'sendFile',        rt,   '',   '/robots.txt'})

meq({kn:lookupRoute(nil,  'GET',  '/upload')},
  {'dirRedir',        rt,         '/upload', ''})

meq({kn:lookupRoute(nil,  'GET',  '/upload/secret.txt')},
  {403,         rt['/upload/'],   '/upload/', '/secret.txt'})

meq({kn:lookupRoute(nil,  'PUT',  '/upload/secret.txt')},
  {'recvFile',  rt['/upload/'],   '/upload/', '/secret.txt'})











print('+OK test passed')
