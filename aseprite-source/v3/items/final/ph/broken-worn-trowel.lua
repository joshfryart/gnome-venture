-- broken-worn-trowel (aB13_0, Opus single pass). A garden trowel: pointed scoop blade upper-left with a raised
-- centre rib, a thin cranked steel neck, brass ferrule, and a long ash handle with a hang hole at the end and its
-- green paint mostly worn off. Material: concave scoop light (lit inside lower-right, lit rolled rim upper-left),
-- 6-tone steel, rib highlight, rust pitting, specular on the rim; handle cylinder light with grain and worn paint
-- patches; brass ferrule with a bright band.
-- broken: the tip has snapped off (flying steel chip) and a jagged crack runs into the blade from the torn edge.
-- quirk: a small snail is taking a ride on the blade.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.pi, math.sqrt
local c = A.new("broken-worn-trowel")
local STEEL = { "#2f3350", "#474a68", "#6d7090", "#9497ae", "#bdbfd0", "#e6e6f0" }
local RUST = { "#6e2c22", "#a0502a", "#c87038" }
local ASH = { "#4a2c2a", "#71472f", "#9d6c43", "#c4995f", "#dfbd7e", "#f3dca4" }
local PAINT = { "#1f4a3f", "#2e6a4a", "#45904f", "#6ab455" }
local BR = { "#5a3020", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff1c0" }
local SPEC = "#f7f7fc"

-- handle first (lower-right)
local HA = A.tube(c, { { 39, 39 }, { 44, 44 }, { 49, 49 }, { 55, 55 } }, function(t)
  if t > 0.9 then return 2.4 - (t - 0.9) * 6 end
  return 2.0 + 0.4 * sin(pi * t)
end, ASH, { bias = function(t) if t < 0.06 then return -1 end return 0 end })
A.grain(c, HA, { { -0.4, 0.05, 0.95, 0.1 }, { 0.3, 0.1, 0.9, 0.12 } })
-- worn green paint: survives in patches on the shade side and the ends
A.over(c, HA, function(t, s, x, y, i)
  local keep = (s > 0.15 and A.X.hash(floor(t * 9), 1, 4) > 0.35) or (t > 0.82 and A.X.hash(x, y, 9) > 0.3)
  if keep and A.X.hash(x, y, 1) > 0.25 then return PAINT[max(1, min(4, i - 2))] end
end)
-- hang hole near the end
do local s = HA.samp[floor(0.82 * 160) + 1]
  local x, y = floor(s.x + .5), floor(s.y + .5)
  c:put(x, y, "#2b1c26") c:put(x + 1, y, ASH[2]) c:put(x, y + 1, ASH[2]) c:put(x - 1, y - 1, ASH[5])
end
-- brass ferrule
local FE = A.tube(c, { { 36, 36 }, { 37, 37 }, { 38, 38 }, { 40, 40 } }, function() return 2.3 end, BR,
  { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
A.over(c, FE, function(t, s, x, y, i) if abs(t - 0.75) < 0.12 then return i - 1 end end)
-- cranked neck
local NK = A.tube(c, { { 28, 27 }, { 31, 31 }, { 32, 33 }, { 36, 36 } }, function() return 0.9 end, STEEL)

-- blade: scoop along tip (11,11) -> base (31,31), tip snapped off
local bp = { { 10, 10 }, { 16, 16 }, { 23, 23 }, { 31, 31 } }
local function bw(t)
  if t > 0.94 then return 3.5 * (1 - (t - 0.94) / 0.06) + 1 end
  return 8.6 * sin(pi * min(1, (t * 0.9) ^ 0.75)) ^ 0.8 * (t < 0.9 and 1 or (1 - (t - 0.9) * 4))
end
local TIP = 0.16
local m, n, T, Sx, samp = A.G.tube(bp, bw)
local cut = HP.mask()
m:each(function(x, y) local k = K(x, y) if T[k] < TIP + A.jag(Sx[k], 1) / 30 then cut:set(x, y) end end)
m:cut(cut)
-- concave normals: flip the across-tilt, keep a raised rib along the centre
local cn = {}
m:each(function(x, y) local k = K(x, y) local nn = n[k] local s = Sx[k]
  if abs(s) < 0.12 then cn[k] = nn
  else cn[k] = { -nn[1] * 0.8, -nn[2] * 0.8, nn[3] } end
end)
local bias = {}
local edge = m:edge()
m:each(function(x, y) local k = K(x, y) local s = Sx[k]
  if edge:has(x, y) then bias[k] = (s < 0) and 2 or -1 end            -- rolled rim catches light upper-left
end)
local v = X.light(cn, { amb = 0.1, wrap = 0.3 })
local btok = { r = { name = "blade" } }
local idx = X.tone(c, m, v, STEEL, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 }, bias = bias, tok = btok })
-- rib: lit ridge line with a dark shade pixel beside it
m:each(function(x, y) local k = K(x, y) local s, t = Sx[k], T[k]
  if t > TIP + 0.12 and t < 0.92 then
    if abs(s) < 0.1 then c:put(x, y, STEEL[5], btok) elseif s > 0.1 and s < 0.24 then c:put(x, y, STEEL[2], btok) end
  end
end)
-- rust pits and stains (worn)
m:each(function(x, y) local k = K(x, y)
  local h = A.X.hash(x, y, 11)
  local zone = (T[k] > 0.62 and Sx[k] > 0.3) or (T[k] < 0.45 and Sx[k] < -0.45 and not edge:has(x, y))
  if zone and h > 0.55 then c:put(x, y, (h > 0.82) and RUST[1] or RUST[2], btok)
  elseif zone and h > 0.45 then c:put(x, y, RUST[3], btok) end
end)
-- torn tip edge: dark broken face
m:each(function(x, y) local k = K(x, y)
  if T[k] < TIP + A.jag(Sx[k], 1) / 30 + 0.04 then c:put(x, y, (Sx[k] < 0) and STEEL[5] or STEEL[2], btok) end
end)
-- crack running in from the torn edge
A.ln(c, { { 18, 14 }, { 19, 16 }, { 18, 18 }, { 20, 20 }, { 21, 23 } }, "#2b1c26")
c:put(19, 14, STEEL[6]) c:put(20, 16, STEEL[6]) c:put(19, 18, STEEL[5]) c:put(21, 20, STEEL[5])
-- specular on the rim
c:put(12, 22, SPEC) c:put(13, 21, SPEC)
-- flying tip chip
local chip = c:poly({ { 7, 8 }, { 11, 8.5 }, { 9, 12 } })
A.slab(c, chip, STEEL, 1)
c:put(8, 8, SPEC)

-- quirk: a snail riding on the blade
A.map(c, 21, 27, {
  "......kk",
  "..gGGgkc",
  ".gGyYGgk",
  "sgYyoGgs",
  "ssgGGgsS",
  ".SSSSSSS",
}, { g = "#c97a3a", G = "#e8a050", y = "#8f4a1f", Y = "#f5c46a", o = "#6e3420",
     s = "#d9c7a8", S = "#a8927a", k = "#7a6a5a", c = "#fff4d6" })
A.fin(c)
