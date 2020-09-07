-- -*- coding: UTF-8, tab-width: 2 -*-

local TU = {}


function TU.tmrOnce(delaySec, cbFunc)
  local t = tmr.create()
  t:alarm(delaySec * 1e3, tmr.ALARM_SINGLE, cbFunc)
  return t
end


function TU.delayed(delaySec, func)
  return function () return TU.tmrOnce(delaySec, func) end
end


return TU
