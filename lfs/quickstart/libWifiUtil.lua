-- -*- coding: UTF-8, tab-width: 2 -*-

local wu
wu = {
  disconCnt = 0,
}

wu.config = {
  maxConnectRetries = 2,
}


function wu.onConnect(ev)
  --[[ event properties:
    BSSID = '01:23:45:ab:cd:ef', -- AP's MAC as lower case hex
    SSID = 'SmartHomeWifi',
    channel = 3,
  --]]--
  wu.disconCnt = 0
  print('[wifi] Connected to network', sjson.encode(ev))
end


function wu.onGotIp(ev)
  --[[ event properties:
    IP = '192.168.0.100',
    gateway = '192.168.0.1',
    netmask = '255.255.255.0',
  --]]--
  print('[wifi] Got IP address', sjson.encode(ev))
end


function wu.onDisconnect(ev)
  local maxRetries = wu.config.maxConnectRetries
  local disCnt = wu.disconCnt + 1
  wu.disconCnt = disCnt
  print(('[wifi] Disconnected, retry #%s of max. %s'
    ):format(ev.reason, disCnt, maxRetries), sjson.encode(ev))

  if wu.disconCnt <= maxRetries then
    print('[wifi] Will retry.')
    if not wu.config.autoConnect then wifi.sta.connect() end
  else
    wifi.sta.disconnect()
    print('[wifi] Gave up.')
  end
end


(function ()
  local em = wifi.eventmon
  em.register(em.STA_CONNECTED, wu.onConnect)
  em.register(em.STA_GOT_IP, wu.onGotIp)
  em.register(em.STA_DISCONNECTED, wu.onDisconnect)
end)()


function wu.connectToAp(cfg)
  if not cfg then return end
  wifi.setmode(wifi.STATION)
  wu.disconCnt = 0

  if cfg.staticIp then
    wifi.sta.setip({
      ip=cfg.staticIp,
      gateway=cfg.gateway,
      netmask=cfg.netmask,
    })
  end
  if cfg.staticIp and cfg.autoConnect then
    print("[wifi] W: staticIp with autoConnect can cause unintended "
      .. "DHCP requests. For details, see "
      .. "https://github.com/nodemcu/nodemcu-firmware/issues/2218")
  end

  local ssid, psk, auto = cfg.ssid, cfg.passwd, cfg.autoConnect
  print(('[wifi] Connecting to SSID %q with a %s-bytes PSK...'
    ):format(ssid, string.len(psk)))
  wifi.sta.config({
    ssid=ssid,
    pwd=psk,
    auto=(auto or false),
  })
  if not auto then wifi.sta.connect() end
end





return wu
