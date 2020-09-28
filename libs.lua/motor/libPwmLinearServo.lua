-- -*- coding: UTF-8, tab-width: 2 -*-

--[[-- Example:
mot = pwmLinearServo({ io_pin=4, pwm_cycle_msec=20,
  dutyA_msec=1, angleA=0,
  dutyB_msec=2, angleB=180,
})
mot(90)

Hint: Some motors have a limit on how far they can rotate with
      only a short PWM sequence. You can try a higher number of
      "repeats", or issue the command again later, or rotate in
      smaller steps.
--]]--



function pwmLinearServo(cfg)
  local pin = cfg.io_pin
  gpio.mode(pin, gpio.OUTPUT, gpio.PULLUP)
  local cycle = cfg.pwm_cycle_msec * 1e3
  local dutyA = cfg.dutyA_msec * 1e3
  local dutyB = cfg.dutyB_msec * 1e3
  local angleA  = cfg.angleA
  local angleB  = cfg.angleB
  local repeats = (cfg.repeats or 5)

  --[[-- How much does the duty cycle increase per angle? (may be negative)
  (dutyB - dutyA) = incr * (angleB - angleA)     | / (xA-nA)
  (dutyB - dutyA) / (angleB - angleA) = incr
  --]]--
  local incr = (dutyB - dutyA) / (angleB - angleA)
  --[[--
  duty = dutyA + ((ang - angleA) * incr)
  duty = dutyA + (ang * incr) - (angleA * incr)
  duty = dutyA - (angleA * incr) + (ang * incr)
  duty =      duty0              + (ang * incr)

  --]]--
  local duty0 = dutyA - (angleA * incr)

  cfg, dutyA, dutyB, angleB = nil

  local gpio_low = gpio.LOW
  local gpio_serout = gpio.serout
  local pattern = {1, 1}
  local duty
  return function (ang, cb)
    duty = duty0 + (ang * incr)
    pattern[1] = cycle - duty
    --[[--^
      PWM idle phase first, then PWM duty phase: I start the sequence
      with the PWM off-duty phase (gpio.LOW) because I want the end
      state to be gpio.HIGH, in order to have my ESP8266's built-in
      GPIO activity LED (blue) be off.
    --]]--
    pattern[2] = duty
    gpio_serout(pin, gpio_low, pattern, repeats, cb or 1)
  end
end









return pwmLinearServo
