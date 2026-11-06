-- _aA7_1.lua: private helpers for ico-monkey, ico-moon, ico-moss-rock, ico-mountain (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
local A = setmetatable({}, { __index = G })
A.INK, A.CR = "#2b1c26", "#fff4d6"
function A.new(name)
  A.c = G.new2(name)
  A.name = name
  return A.c
end
-- quantise a value field v[k] to ramp with bias; returns idx
function A.paintV(m, v, ramp, cuts, bias, tok)
  return X.tone(A.c, m, v, ramp, { cuts = cuts, bias = bias, tok = tok or { r = { name = tostring(ramp) } } })
end
-- lit from normals with standard opts
function A.litN(m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.vmod then for k, val in pairs(v) do v[k] = o.vmod(k, val) end end
  return A.paintV(m, v, ramp, o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, o.bias, o.tok), v
end
function A.fill(m, hex) m:each(function(x, y) A.c:px(x, y, hex) end) end
function A.pts(list, hex) for _, p in ipairs(list) do A.c:px(p[1], p[2], hex) end end
function A.bmp(rows, x0, y0, map)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if map[ch] then A.c:px(x0 + xx - 1, y0 + yy - 1, map[ch]) end end end
end
-- current colour at pixel (nil if empty)
function A.at(x, y) local i = y * A.c.w + x return A.c.pix[i] end
function A.done() G.save2(A.c, A.name) end
return A
