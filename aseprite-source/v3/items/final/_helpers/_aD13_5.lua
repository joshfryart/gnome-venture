-- _aD13_5: private helpers for saffron-seed, sages-draught, sago, sago-seed (Sonnet high, single pass).
-- Read-only wrap of batch2/_b2g1.lua (-> batch1/_g1.lua). Adds a pixel line and a sphere painter.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
G.out = app.params.out or "./"
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
-- 1px Bresenham-ish line; hex may be fn(x,y,i,n) -> hex|nil
function G.bres(c, x0, y0, x1, y1, hex, tok)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    local h = hex
    if type(hex) == "function" then h = hex(x, y, i, n) end
    if h then c:put(x, y, h, tok) end
  end
end
-- integer-centred disc mask, radius r (5x5 minus corners for r=2.4)
function G.disc(cx, cy, r)
  local m = HP.mask()
  for y = floor(cy - r) - 1, floor(cy + r) + 1 do for x = floor(cx - r) - 1, floor(cx + r) + 1 do
    if (x - cx) ^ 2 + (y - cy) ^ 2 <= r * r + 0.01 then m:set(x, y) end
  end end
  return m
end
-- sphere-lit disc; ramp 6 tones; returns mask, idx table
function G.sph(c, cx, cy, r, ramp, o)
  o = o or {}
  local m = o.mask or G.disc(cx, cy, r)
  local n = X.sphere(cx - 0.4, cy - 0.4, r, m)
  local idx = G.toneN(c, m, n, ramp, { bias = o.bias, tok = o.tok, cuts = o.cuts or { 0.2, 0.36, 0.54, 0.7, 0.86 }, amb = o.amb or 0.06, wrap = o.wrap or 0.2 })
  return m, idx, n
end
return G
