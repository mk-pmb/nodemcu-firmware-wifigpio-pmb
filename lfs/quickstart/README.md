
Quickstart
==========

I haven't figured out yet how to autostart LFS modules directly,
so for now I recommend you add a minimal `init.lua`:

```lua
file.putcontents('init.lua',
  "print('sysInit:', pcall(function () return node.LFS.get('sysInit')() end))")
```

The `sysInit` module will prepare some useful basics and schedule a
`require('appInit')` a few seconds later. In case your appInit causes
a reboot loop, this delay gives you an opportunity to quickly paste
a rescue command into your UART, like this one:

```lua
= file.putcontents('appInit.lua', ''), file.remove('appInit.lc', '')
```
