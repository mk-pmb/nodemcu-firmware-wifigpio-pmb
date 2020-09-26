-- -*- coding: UTF-8, tab-width: 2 -*-

local modName = ...
local modPfx = modName:match('^.+[%.%/]') or ''

local futil = require(modPfx .. 'libFileUtil')
local tabu = require(modPfx .. 'libTableUtil')

local mr = {}
local humanSz = futil.humanFlashSz

function mr.lspt ()
  local ptRaw = node.getpartitiontable()
  local parts = {}
  local leftovers = {}
  local name, prop
  for k, v in pairs(ptRaw) do
    name, prop = k:match('^(.+)_([a-z]+)$')
    if prop == 'addr' then
      table.insert(parts, { name=name, addr=v, size=ptRaw[name .. '_size'] })
    elseif prop == 'size' then
      -- ignore
    else
      table.insert(leftovers, ('%q=%q'):format(k, v))
    end
  end
  table.sort(parts, function (a, b) return a.addr < b.addr end)
  local output = {}
  local function human(x) return humanSz(x, '()') end
  for i, p in ipairs(parts) do
    table.insert(output, ('%s @0x%x%s +0x%x%s'):format(p.name,
      p.addr, human(p.addr), p.size, human(p.size)))
  end
  table.sort(leftovers)
  for i, p in ipairs(leftovers) do table.insert(output, p) end
  return table.concat(output, ', ')
end

function mr.du ()
  local free, used, total = file.fsinfo()
  local capa = ('%s total - %s used = %s free'
    ):format(humanSz(total), humanSz(used), humanSz(free))
  local ptntbl = mr.lspt()
  print('Capacity [bytes]: ' .. capa
    .. ', partition table: ' .. ptntbl)
  local files = file.list()
  local function fmt(p) return (p.key .. ' (' .. humanSz(p.val) .. ')') end
  files = tabu.pairsList(files, { sort=true, mapAfterSort=fmt })
  print('Files: ' .. table.concat(files, ', '))
end


return mr
