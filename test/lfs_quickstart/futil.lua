-- -*- coding: UTF-8, tab-width: 2 -*-

dofile('../mcuStubs.lua')

local futil = require('qs/libFileUtil')
print('ls: ' .. futil.ls())

local flashMemoryReport = require('qs/libFlashMemoryReport')
flashMemoryReport.du()
