-- -*- coding: UTF-8, tab-width: 2 -*-

local TU = {
  makePicker = function (p) return function(x) return x[p] end end,
}

local function compareKeys (a, b) return a.key < b.key end

function TU.printDict(t, opt)
  if not opt then opt = {} end
  print(tostring(opt.descr or '??') .. ' = {')
  local s = opt.sort
  if s == nil then s = true end
  local k, v
  for i, p in ipairs(TU.pairsList(t, { sort=s })) do
    k, v = p.key, p.val
    t = type(v)
    v = tostring(v)
    if t == 'number' then
    elseif t == 'string' then
      v = ('%q'):format(v)
    else
      v = ('%q\t-- %s'):format(v, t)
    end
    print(('  [%q] = %s,'):format(tostring(k), v))
  end
  print('}')
end


function TU.flip(t, dest, prefix)
  if not dest then dest = {} end
  for k, v in pairs(t) do
    if prefix then v = prefix .. tostring(v) end
    dest[v] = k
  end
  return dest
end


function TU.update(dest, src)
  if not dest then return TU.update({}, src) end
  if not src then return dest end
  for key, val in pairs(src) do dest[key] = val end
  return dest
end


function TU.pairsList(t, opt)
  if not opt then opt = {} end
  local l = {}
  for k, v in pairs(t) do table.insert(l, {key=k, val=v}) end

  local s = opt.sort
  if opt.mapBeforeSort then l = TU.map(l, opt.mapBeforeSort) end
  if s == true then s = compareKeys end
  if type(s) == 'function' then table.sort(l, s) end
  if opt.mapAfterSort then l = TU.map(l, opt.mapAfterSort) end

  return l
end


function TU.mapInto(dest, t, f)
  for k, v in pairs(t) do dest[k] = f(v, k, t) end
  return dest
end

function TU.map(t, f) return TU.mapInto({}, t, f) end

function TU.keys(t)
  return TU.pairsList(t, {
    -- We can always sort without regard for original key order,
    -- because Lua doesn't preserve key order to begin with.
    sort=true,
    mapAfterSort=TU.makePicker('key'),
  })
end


return TU
