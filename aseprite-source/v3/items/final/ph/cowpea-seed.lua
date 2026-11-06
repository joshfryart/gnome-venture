-- cowpea-seed (final, Opus single pass). Three black-eyed cowpea seeds (cream kidneys, a dark ring eye with a
-- pale hilum slit on the concave side, wrinkled coat flecks) on a torn scrap of a glossy cowpea leaflet (ragged
-- torn base, midrib + paired veins, V-fold light, cool reflected edge, AO + contact shadow under each seed).
-- The right seed has sprouted: pale hypocotyl, two thick fleshy cotyledons, and the first pair of spear-shaped
-- (hastate) true leaves that show the cowpea leaf.
-- quirk: the sprout still wears half its seed coat as a little cap, eye and all, on the growing tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "cowpea-seed"
local c = A.new(NAME)
local LEAF = { "#163a36", "#1f553f", "#2b7346", "#40924d", "#62b257", "#96d06e" }
local COOL = "#3a6a72"
local SEED = { "#8a6656", "#b08a70", "#d2b08c", "#ead0a6", "#f8e8c4", "#fff6de" }
local EYE, EYE2 = "#2b1c26", "#4a3040"
local STEM = { "#5a8a52", "#8ab86a", "#b8d890", "#e0f0b8" }
local COT = { "#4c6a34", "#7a9644", "#a8bc5a", "#cfd67a", "#ece8a4" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 49, 4.6, 3.0, -0.12 }, { 28, 47, 4.5, 2.9, 0.28 }, { 40, 44, 4.4, 2.9, -0.22 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8)
  -- kidney notch on the upper long side
  local ca, sa = cos(s[5]), sin(s[5])
  s.hx, s.hy = s[1] + sa * (s[4] + 0.6), s[2] - ca * (s[4] + 0.6)
  s.m:cut(A.rell(s.hx, s.hy, ca, sa, 1.8, 1.2))
end

-- torn leaf scrap
local lm, ln, LT, LS, len = A.blade(8, 55, 30, 58, 55, 42, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.9 + 0.1)
  return max(0.5, 9.0 * sin(pi * u ^ 1.05) ^ 0.65)
end, { fold = 0.4 })
-- ragged torn base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + 0.07 * X.hash(floor(LS[k] * 5), 3, 11) + 0.03 * ((x + y) % 2)
  if LT[k] < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- a bite-shaped tear on the lower margin
lm:cut(A.rell(30, 61, 1, 0, 3.2, 2.6))

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.1 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 9 * 1.0) % 6.5
  if d < 0.9 and abs(s) > 0.2 and abs(s) < 0.78 and t > 0.14 and t < 0.88 then c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibre pixels along the ragged base
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.2 and not bias[k] then c:put(x, y, LEAF[5], ltok) end end)
-- glossy leaf glint
c:put(22, 51, "#d2f0a0", ltok) c:put(23, 51, "#d2f0a0", ltok)

-- sprout: hypocotyl
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 40, 43 }, { 38, 35 }, { 41, 28 }, { 40, 21 } }, function(t) return 1.15 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
-- true leaves (hastate: spear with small basal lobes)
local ltok2 = { r = { name = "trueleaf" } }
local function hast(bx, by, cx, cy, tx, ty)
  local m, T, S = A.leaf(c, bx, by, cx, cy, tx, ty, 3.4, LEAF, { tok = ltok2, pw = 0.5, vs = 3.0, wfn = function(t)
    if t > 0.985 then return -1 end
    local w = 3.4 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.5
    if t > 0.12 and t < 0.3 then w = w + 1.1 * sin(pi * (t - 0.12) / 0.18) end
    return max(0.4, w)
  end })
  return m
end
local L1 = hast(39, 21, 33, 13, 25, 15)
local L2 = hast(41, 21, 47, 13, 55, 15)
L1:add(L2)
-- cotyledons: fleshy half-bean lobes at the stem's waist
local ctok = { r = { name = "cotyledon" } }
for _, q in ipairs{ { 35.3, 33.5, 0.35 }, { 44.6, 32.5, -0.35 } } do
  local m, n = A.oval(q[1], q[2], 3.6, 2.4, q[3], 0.7)
  m:cut(sm)
  local cb = {} X.ao(cb, m, sm, 1, -1)
  A.shade(c, m, n, COT, { tok = ctok, bias = cb, cuts = { 0.24, 0.45, 0.65, 0.84 }, amb = 0.14, wrap = 0.3 })
end
-- quirk: seed-coat cap on the growing tip
do
  local cap = A.rell(40, 20.2, 1, 0, 3.1, 2.3):clip(c:rect(30, 10, 50, 20))
  local capb, ctk = {}, { r = { name = "cap" } }
  cap:each(function(x, y)
    local i = (y < 19 and x < 40) and 6 or (y < 20 and 5 or 4)
    if x >= 42 then i = i - 1 end
    c:put(x, y, SEED[i], ctk)
  end)
  c:put(39, 19, EYE, ctk) c:put(40, 19, EYE, ctk) c:put(40, 18, EYE2, ctk)
  -- contact shadow on the stem/leaf junction under the cap
  for x = 38, 42 do if c:get(x, 21) then c:put(x, 21, STEM[1], stok) end end
end

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) vis:cut(sm) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.12, wrap = 0.3, cuts = { 0.18, 0.36, 0.54, 0.72, 0.9 } })
  -- wrinkled coat flecks
  vis:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, 21 + i) > 0.86 and idx[k] and idx[k] >= 3 and idx[k] <= 5 then c:put(x, y, SEED[idx[k] - 1], tok) end end)
  -- black eye ring at the hilum
  local ca, sa = cos(s[5]), sin(s[5])
  local ex, ey = s.hx - sa * 1.5, s.hy + ca * 1.5
  local ring = A.rell(ex, ey, ca, sa, 2.4, 1.5):clip(vis)
  ring:each(function(x, y) c:put(x, y, EYE, tok) end)
  local core = A.rell(ex, ey - 0.3, ca, sa, 1.2, 0.5):clip(ring)
  core:each(function(x, y) c:put(x, y, EYE2, tok) end)
  -- glint
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx and not ring:has(gx, gy) then c:put(gx, gy, "#fffcee", tok) end
end

A.save(c, NAME)
