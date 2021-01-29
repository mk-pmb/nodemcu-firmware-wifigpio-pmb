-- -*- coding: UTF-8, tab-width: 2 -*-

local moduleName = ...
local modulePrefix = moduleName:match('^.+[%.%/]') or ''
local tabu = require(modulePrefix .. 'libTableUtil')


local futil = {}

local function floatUnit(x, u)
  x = ('%0.2f'):format(x)
  x = (x:match('^(.+)%.0*$') or x)
  return x .. (u or '')
end

function futil.humanFlashSz(bytes, fmt)
  if not fmt then
    fmt = floatUnit
  elseif fmt == '()' then
    fmt = function (num, unit)
      if not unit then return '' end
      return (' (' .. floatUnit(num, unit) .. ')')
    end
  end
  local k = bytes / 1024
  if k < 2 then return fmt(bytes) end
  local m = k / 1024
  if m < 2 then return fmt(k, 'k') end
  return fmt(m, 'M')
end


function futil.ls (opt)
  local names = tabu.keys(file.list())
  return table.concat(names, ', ')
end


return futil
