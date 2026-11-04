-- grains-of-paradise-seed (B3, Opus single pass aB35_3). Four glossy, angular red-brown grains of paradise on a torn scrap
-- of the plant's long ginger-family leaf: parallel monocot veins, V-fold light along the midrib, cool reflected lower edge,
-- jagged torn base, AO and contact shadows under the grains. One grain has sprouted a pale pseudostem with a rolled spike
-- and a first narrow lance leaf arching up-left (the plant's leaf shape).
-- quirk: a tiny pink-violet flower bud pokes out at the foot of the sprout, as the real plant flowers at ground level.
local NAME = "grains-of-paradise-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#183e36", "#22583e", "#2f7448", "#46924e", "#6cb258", "#a2d072" }
local VEIN, COOL, TORN = "#bfe28a", "#36686e", "#d0e8a0"
local SD = { "#2e1016", "#561c1e", "#7e2c22", "#a8442a", "#d06c3e", "#f2a066" }
local STEM = { "#4e8650", "#8aba6a", "#bcdc92", "#e6f4c0" }
local BUD = { "#5e2a5e", "#9a4a8e", "#d27ab4", "#f6b6d8" }
local CREAM = "#fff4d6"

-- leaf scrap: long lance blade, torn base on the right
local lm, ln, LT, LS, len = A.blade(52, 50, 32, 38, 8, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.2 * sin(pi * min(1, 0.32 + t * 0.7)) ^ 0.7)
end, { fold = 0.4 })
-- jagged torn base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.04 + 0.05 * X.hash(floor(LS[k] * 6), 1, 2) then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local tornEdge = HP.mask()
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.12 and not lm:has(x + 1, y) and x > 44 then tornEdge:set(x, y) end end)

-- grains: angular, sit on the blade
local grains = { { 18, 42, 3.0, 2.3, 0.3 }, { 25, 45, 3.0, 2.2, -0.2 }, { 33, 41, 2.9, 2.3, 0.5 }, { 40, 45, 2.8, 2.2, -0.4 } }
for _, g in ipairs(grains) do
  local m, n = A.oval(g[1], g[2], g[3], g[4], g[5], 0.7)
  -- facet it: clip two corners for an angular grain
  local ca, sa = cos(g[5]), sin(g[5])
  m:each(function(x, y) local u = (x - g[1]) * ca + (y - g[2]) * sa local v = -(x - g[1]) * sa + (y - g[2]) * ca
    if u + v > g[3] + 0.3 or -u - v > g[3] + 0.6 then m.s[K(x, y)] = nil end end)
  g.m, g.n = m, n
end

local bias = {}
for _, g in ipairs(grains) do X.ao(bias, lm, g.m, 1, -1) A.cast(bias, lm, g.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- midrib + parallel veins (monocot), converging to the tip
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local r = abs(((abs(s) * 3.6) % 1) - 0.5)
  if r < 0.1 and abs(s) > 0.2 and abs(s) < 0.85 and t > 0.08 and t < 0.9 then
    c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 3) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
tornEdge:each(function(x, y) c:put(x, y, TORN, ltok) end)

-- sprout from grain 3 --------------------------------------------------------------
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 34, 40 }, { 35, 33 }, { 35, 27 }, { 36, 21 } }, function(t) return 1.5 - 0.5 * t end)
sm:cut(grains[3].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
-- rolled spike continuing straight up, sheath line
local km, kn = A.tube({ { 36, 22 }, { 36, 18 }, { 37, 15 }, { 38, 12 } }, function(t) return 1.1 * (1 - t) ^ 0.8 + 0.2 end)
A.shade(c, km, kn, LEAF, { amb = 0.12, wrap = 0.3, tok = stok })
for y = 24, 34, 3 do c:put(35, y, STEM[1], stok) end
-- first lance leaf arching up-left from the sheath
local fm = A.leaf(c, 35, 26, 27, 14, 14, 16, 3.3, LEAF, { pw = 0.7, vs = 2.6, cut = sm })

-- quirk: flower bud at the foot of the sprout
local bm, bn = A.oval(38.5, 37, 1.7, 2.6, -0.5, 0.8)
local btok = { r = { name = "bud" } }
A.shade(c, bm, bn, BUD, { cuts = { 0.24, 0.5, 0.75 }, tok = btok })
c:put(38, 35, BUD[4], btok) c:put(40, 39, STEM[2], btok) c:put(39, 40, STEM[1], btok)

-- grains last: faceted, glossy
for i, g in ipairs(grains) do
  local vis = g.m:copy()
  local gb = {}
  local tok = { r = { name = "grain" .. i } }
  local idx = A.shade(c, vis, g.n, SD, { amb = 0.06, wrap = 0.2, tok = tok, bias = gb })
  -- facet ridge: one darker diagonal line
  vis:each(function(x, y) local k = K(x, y)
    if (x - g[1]) - (y - g[2]) == 1 and idx[k] > 2 then c:put(x, y, SD[idx[k] - 1], tok) end end)
  local sx, sy = A.specAt(vis, g.n, 40)
  if sx then c:put(sx, sy, (i == 2) and CREAM or SD[6], tok) end
end

A.save(c, NAME)
