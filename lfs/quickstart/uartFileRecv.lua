-- -*- coding: UTF-8, tab-width: 2 -*-
local ufr
ufr = {
  libName = 'uartFileRecv',
  un = encoder.fromBase64,
  ln = '',
}

ufr.tmpfn = ('tmp.%s.up'):format(ufr.libName)
ufr.codecs = {
  asc = tostring,
  b64 = ufr.un,
}

function ufr.log(fmt, ...)
  if ufr.lateEol then uart.write(0, ufr.lateEol) end
  ufr.lateEol = nil
  if select('#', ...) > 0 then fmt = fmt:format(...) end
  uart.write(0, ('[%s] %s\r\n'):format(ufr.libName, fmt))
end

function ufr.reinit()
  if ufr.fh then ufr.fh:close() end
  ufr.fh = nil
  ufr.noisy = nil
end

function ufr.save(fn)
  local err = (
    (ufr.noisy and 'noisy') or
    nil)
  ufr.reinit()
  if err then
    file.remove(ufr.tmpfn)
    return ufr.log('del %q (%s)', ufr.tmpfn, err)
  end
  if (fn or '') == '' then
    file.remove(ufr.tmpfn)
    return ufr.log('del %q (requested)', ufr.tmpfn)
  end
  file.remove(fn)
  if not file.rename(ufr.tmpfn, fn) then
    return ufr.log('FAILED to rename %q -> %q!', ufr.tmpfn, fn)
  end
  ufr.log('ren %q -> %q', ufr.tmpfn, fn)
  local err, hash = pcall(function ()
    return encoder.toHex(crypto.fhash('sha1', fn))
  end)
  ufr.log('%s checksum: %s', fn, hash)
  ufr.refine(fn)
end

function ufr.refine(fn)
  if fn:match('%.lua$') then ufr.tryCompile(fn) end
end

function ufr.postprocess(fn)
  local ok, why = pcall(node.compile, fn)
  if ok then return ufr.log('compiled %q', fn) end
  ufr.log('failed to compiled %q: %s', fn, why)
end

function ufr.restoreRepl()
  ufr.reinit()
  uart.on('data')
  ufr.log('resume REPL.')
  node.input('\n')
end

function ufr.tryDecode(x)
  local ok, y = pcall(ufr.un, x)
  if ok then return y end
  ufr.log('ignored %s bytes of noise (%s): %q', x:len(), y, x)
  ufr.noisy = true
end

function ufr.parse(ln)
  if ln == '' then return end
  local c1 = ln:sub(1, 1)
  if c1 == '.' then return ufr.restoreRepl() end
  if c1 == '>' then return ufr.save(ln:sub(2)) end
  if c1 == '$' then
    ufr.un = assert(ufr.codecs[ln:sub(2)])
    return
  end
  ln = ufr.tryDecode(ln)
  if not ln then return end
  ufr.fh = ufr.fh or file.open(ufr.tmpfn, 'w')
  ufr.fh.write(ln)
  uart.write(0, '+')
  ufr.lateEol = '\r\n'
end

function ufr.rdch(ch)
  if ch == '\r' or ch == '\n' then
    ufr.parse(ufr.ln)
    ufr.ln = ''
  else
    ufr.ln = ufr.ln .. ch
  end
end

function ufr.now()
  uart.on('data', 1, ufr.rdch, 0)
  ufr.log('ready.')
end
setmetatable(ufr, {__call=ufr.now})

return ufr
