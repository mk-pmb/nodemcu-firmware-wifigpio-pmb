-- -*- coding: utf-8, tab-width: 2, lfs: no -*-

timeUtil = require('libTimeUtil')
tabu = require('libTableUtil')
ufr = require('uartFileRecv')
dir = tabu.printDict

futil = require('libFileUtil')
function ls() print(futil.ls()) end
require('libFlashMemoryReport').du()

cfg = (require('cfg_basics') or {})
if cfg.wifi then require('libWifiUtil').connectToAp(cfg.wifi) end
if cfg.knecht then
  knSrv = require('libDavidKnecht').spawn(cfg.knecht)
  knRt = knSrv.routesDict
end

(function () -- I²C setup
  busId   = 0
  pinSCL  = 1  -- D1 | Mnemonic: First we need a clock, because the
  pinSDA  = 2  -- D2 | data channel would be useless without it.
  i2c.setup(busId, pinSDA, pinSCL, i2c.FAST)
end)()



















--
