-- ico-pkplant0..4 (perks popover growth ladder, one new feature per stage): seed in the soil, sprout, two leaf pairs, bud, bloom.
-- Same terracotta pot in the same place every time; quirk on every stage: a small snail waits at the pot's foot.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local P = dofile(DIR .. "/_pk.lua")
local A, HP, X, K = P.A, P.HP, P.X, P.K
local sin, cos, pi, max, min = math.sin, math.cos, math.pi, math.max, math.min

local function stage(n)
  local c = P.new("ico-pkplant" .. n)
  local soil = P.pot(c)
  P.snail(c, 4, 52)
  if n == 0 then   -- a fat gold seed half-sunk in the soil, with a split and a root tip
    local m = c:ellipse(32, 39, 5, 3.4):clip(c:rect(0, 0, 63, 41))
    A.shade(c, m, X.sphere(32, 38.5, 4.6, m), P.GD, { cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, tok = P.tok.misc })
    c:put(30, 37, P.GD[6], P.tok.misc) c:put(31, 36, P.GD[5], P.tok.misc)
    c:put(33, 38, P.GD[1], P.tok.misc) c:put(34, 39, P.GD[1], P.tok.misc)
  elseif n == 1 then
    local sm = P.stem(c, 32, 40, 32, 30, 1.45)
    P.leaf(c, 31, 33, 22, 29, 15, 34, 5.0, sm) P.leaf(c, 33, 32, 41, 26, 48, 29, 5.0, sm)
  elseif n == 2 then
    local sm = P.stem(c, 32, 40, 32, 17, 1.45)
    P.leaf(c, 31, 36, 21, 32, 12, 37, 6.2, sm) P.leaf(c, 33, 35, 43, 31, 53, 35, 6.2, sm)
    P.leaf(c, 31, 26, 23, 20, 15, 22, 5.4, sm) P.leaf(c, 33, 24, 41, 17, 49, 18, 5.4, sm)
  elseif n == 3 then
    local sm = P.stem(c, 32, 40, 32, 17, 1.45)
    P.leaf(c, 31, 36, 21, 32, 12, 37, 6.2, sm) P.leaf(c, 33, 35, 43, 31, 53, 35, 6.2, sm)
    P.leaf(c, 31, 28, 24, 24, 17, 27, 5.0, sm)
    -- bud: pink teardrop with a lit side, green sepals hugging it
    local bm = c:ellipse(32, 12, 6.2, 7.6)
    local bn = X.sphere(32, 12, 6.8, bm)
    local bi = A.shade(c, bm, bn, P.PT, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = P.tok.misc })
    for y = 8, 18 do c:put(32, y, P.PT[max(1, (bi[K(32, y)] or 3) - 1)], P.tok.misc) end          -- petal seam
    c:put(29, 8, P.PT[6], P.tok.misc) c:put(30, 7, P.PT[5], P.tok.misc)
    P.leaf(c, 31, 20, 26, 17, 25, 12, 2.4, nil) P.leaf(c, 33, 20, 38, 17, 39, 12, 2.4, nil)
  else
    local sm = P.stem(c, 32, 40, 32, 22, 1.45)
    P.leaf(c, 31, 36, 21, 32, 12, 37, 6.2, sm) P.leaf(c, 33, 35, 43, 31, 53, 35, 6.2, sm)
    local cx, cy = 32, 13
    for k = 0, 7 do   -- eight petals, light ones on the lit upper-left
      local a = k * pi / 4 + pi / 8
      local tx, ty = cx + cos(a) * 11, cy + sin(a) * 11
      local mx, my = cx + cos(a + 0.18) * 6, cy + sin(a + 0.18) * 6
      local lit = (cos(a) * -0.6 + sin(a) * -0.8) > 0
      local m, nn = A.blade(cx, cy, mx, my, tx, ty, function(t) if t > 0.985 then return -1 end return max(0.8, 4.2 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.6) end, { fold = 0.2 })
      A.shade(c, m, nn, P.PT, { cuts = { 0.14, 0.28, 0.44, 0.6, 0.78 }, amb = lit and 0.2 or 0.05, wrap = 0.3, tok = P.tok.misc })
    end
    local em = c:ellipse(cx, cy, 5, 5)
    A.shade(c, em, X.sphere(cx, cy, 5, em), P.GD, { cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, tok = P.tok.misc })
    c:put(cx - 2, cy - 2, P.GD[6], P.tok.misc) c:put(cx - 1, cy - 3, P.GD[6], P.tok.misc)
    c:put(cx + 1, cy + 2, P.GD[1], P.tok.misc) c:put(cx - 1, cy + 1, P.GD[2], P.tok.misc)       -- seed dots in the eye
  end
  P.finish(c, "ico-pkplant" .. n)
end
for n = 0, 4 do stage(n) end
