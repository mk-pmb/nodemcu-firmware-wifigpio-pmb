-- -*- coding: UTF-8, tab-width: 2 -*-

for pin = 1, 8 do gpio.mode(pin, gpio.OPENDRAIN); gpio.write(pin, 1); end

table.insert(package.loaders, function (m)
  return node.LFS.get(m) or ('\n\t no module %q in LFS'):format(m)
end)

tmr.create():alarm(2e3, tmr.ALARM_SINGLE, function ()
  print('appInit:', pcall(require, 'appInit'))
end)

return unpack(require('_buildID'))
