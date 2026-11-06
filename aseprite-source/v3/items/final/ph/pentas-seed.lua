-- pentas-seed (final, Opus aC33_1). Five tiny angular dark-brown pentas seeds huddled on a torn, drooping pentas leaf
-- scrap (lanceolate, deeply impressed curved lateral veins, pale midrib, jagged torn base, cool reflected edge, AO +
-- contact shadow under each seed). The middle seed has germinated: slim pale stem, a pair of round cotyledons, then a
-- pair of narrow ribbed true leaves (the pentas leaf shape).
-- quirk: the seedling already wears one open pink five-point star floret on top.
local NAME = "pentas-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#173d34", "#245a3e", "#33794a", "#4f9a50", "#78b85a", "#aad47a" }
local COOL = "#3b6e74"
local SEED = { "#2a1618", "#4a2a22", "#6c4028", "#905a34", "#b47c48", "#d8a66a" }
local STEM = { "#3e7a4c", "#6aa65a", "#a2d07a", "#d6eeac" }
local PINK = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 19, 47, 2.6, 1.7, 0.5 }, { 25, 49, 2.4, 1.6, -0.3 }, { 31, 46, 2.7, 1.8, 0.15 }, { 37, 49, 2.4, 1.5, 0.9 }, { 23, 43, 2.2, 1.5, -0.7 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: drooping lanceolate pentas leaf, torn straight-ish across the base (left), pointed tip (right)
local lm, ln, LT, LS, len = A.blade(8, 47, 31, 37, 56, 51, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, 0.3 + t * 0.72)) ^ 0.8)
end, { fold = 0.4 })
-- torn base: jagged bite out of the left end
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.09 then
    local j = ({ 0, 2, 1, 3, 1, 0, 2, 3, 1, 2, 0, 1, 3, 2, 1, 0, 2, 1 })[(y % 18) + 1]
    if LT[k] * len < j + 0.5 then torn[#torn + 1] = k end
  end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- veins: pale midrib, deeply impressed curved laterals (dark groove with a lit lip on the light half)
local VS = 5.2
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t, i = LS[k], LT[k], lidx[k] or 3
  if abs(s) < 0.13 and t > 0.06 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[4], ltok) return end
  if t > 0.08 and t < 0.88 and abs(s) > 0.2 and abs(s) < 0.86 then
    local d = (t * len - abs(s) ^ 1.4 * 7.5) % VS
    if d < 0.9 then c:put(x, y, LEAF[max(1, i - 2)], ltok)
    elseif d < 1.9 and s < 0 then c:put(x, y, LEAF[min(6, i + 1)], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: pale broken edge on the torn base
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.08 then c:put(x, y, (y % 2 == 0) and LEAF[5] or "#c8e29a", ltok) end end)

-- sprout from the middle seed: slim stem, round cotyledons, narrow ribbed true leaves, star floret
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 31, 45 }, { 30, 36 }, { 33, 26 }, { 32, 15 } }, function(t) return 1.0 end, STEM, { tok = stok, cut = seeds[3].m })
local function lf(ax, ay, cx, cy, bx, by, w, pw)
  local m = A.leaf(c, ax, ay, cx, cy, bx, by, w, LEAF, { cut = sm, pw = pw or 0.7, vs = 2.6, fold = 0.5, tok = ltok })
  return m
end
-- round cotyledons low on the stem
local cot = HP.mask()
for _, q in ipairs{ { 29, 35, 24, 34, 21, 36 }, { 32, 34, 37, 32, 40, 34 } } do
  local m, n = A.blade(q[1], q[2], q[3], q[4], q[5], q[6], function(t) if t > 0.97 then return -1 end return max(0.5, 2.2 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.45) end, { fold = 0.2 })
  m:cut(sm) cot:add(m)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
end
-- narrow true leaves (pentas: lanceolate, ribbed)
local l1 = lf(32, 25, 25, 20, 18, 22, 2.6)
local l2 = lf(33, 24, 40, 18, 47, 19, 2.6)
-- top floret: five-point pink star, cream eye
local fx, fy = 32, 11
local star = { { 0, -3 }, { 0, -2 }, { -1, -1 }, { 0, -1 }, { 1, -1 }, { -3, -1 }, { -2, -1 }, { 2, -1 }, { 3, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 },
  { -2, 0 }, { 2, 0 }, { -1, 1 }, { 1, 1 }, { -2, 2 }, { 2, 2 }, { -2, 1 }, { 2, 1 } }
local ftok = { r = { name = "floret" } }
for _, p in ipairs(star) do
  local x, y = p[1], p[2]
  local col = PINK[3]
  if x + y < -2 then col = PINK[4] elseif x + y > 1 or y == 2 then col = PINK[2] end
  c:put(fx + x, fy + y, col, ftok)
end
c:put(fx, fy, "#ffe38a", ftok) c:put(fx - 1, fy - 1, PINK[4], ftok)
c:put(fx, fy + 1, PINK[1], ftok)
for y = fy + 2, 14 do c:put(fx, y, STEM[2], stok) end

-- seeds last: angular, dull, ridged, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  local idx = X.tone(c, vis, v, SEED, { cuts = { 0.18, 0.35, 0.52, 0.7, 0.86 }, bias = sb, tok = tok })
  -- one dark wrinkle along each seed
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local v2 = -dx * sa + dy * ca
    if abs(v2 - 0.3) < 0.5 and abs(dx * ca + dy * sa) < s[3] - 0.8 then c:put(x, y, SEED[max(1, (idx[K(x, y)] or 3) - 2)], tok) end end)
end
-- split seed coat edge where the stem leaves it, one pale hilum on the front seed
c:put(30, 45, SEED[6], { r = { name = "seed3" } })
c:put(24, 48, SEED[6], { r = { name = "seed2" } })
A.save(c, NAME)
