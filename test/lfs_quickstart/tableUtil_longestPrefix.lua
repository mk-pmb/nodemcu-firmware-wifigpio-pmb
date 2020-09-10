-- -*- coding: UTF-8, tab-width: 2 -*-

dofile('../mcuStubs.lua')
local test = require('qs/libTestUtil')
local meq = test.multi('eq')

local tabu = require('qs/libTableUtil')
local lpk = tabu.longestPrefixKey

local routes = {
  ['/'] = 'index',
  ['/favicon.ico'] = 'favi',
  ['/dav/'] = 'davroot',
  ['/dav/foo'] = 'davdl',
  ['/dav/bar/'] = 'davdir',
}
meq({lpk(routes, '/')}, {'/', 'index'})
meq({lpk(routes, '/favicon.ico')}, {'/favicon.ico', 'favi'})
meq({lpk(routes, '/robots.txt')}, {'/', 'index'})
meq({lpk(routes, '/dav/')}, {'/dav/', 'davroot'})
meq({lpk(routes, '/dav/foo/')}, {'/dav/foo', 'davdl'})
meq({lpk(routes, '/dav/bar/')}, {'/dav/bar/', 'davdir'})










print('+OK test passed')
