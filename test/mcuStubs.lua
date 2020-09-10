-- -*- coding: UTF-8, tab-width: 2 -*-

file = {}

function file.list()
  return {
    ['cfg.wifi.lua'] = 128,
    ['secrets.wifi_psk.lua'] = 2020,
    ['libTableUtil.lua'] = 32000,
    ['init.lua'] = 4200,
  }
end

function file.fsinfo () return 9009, 500, 2300230 end

node = {}

function node.getpartitiontable ()
  return {
    lfs_addr    = 0x000ba000,   lfs_size    = 0x00030000,
    spiffs_addr = 0x000ea000,   spiffs_size = 0x00313000,
  }
end
