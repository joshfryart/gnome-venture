-- forget-me-not-seed (B3, Opus single pass). Three glossy jet-brown forget-me-not nutlets (teardrop, keeled, one bright
-- specular each) on a torn, soft-haired grey-green forget-me-not leaf scrap (ragged tear on the left end, midrib, swept
-- veins, pale hairs on the rim, AO and contact shadow under each nutlet). The right nutlet has sprouted: pale stem, two
-- round cotyledons and a pair of oblong, hairy true leaves that show the plant's leaf shape.
-- quirk: the seedling is already showing off a single tiny sky-blue flower with a yellow eye.
local NAME = "forget-me-not-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF = { "#1c3a36", "#2a5446", "#3c7052", "#578d5c", "#7cab6c", "#abc98a" }
local HAIR, COOL = "#d6e8b8", "#3c6a74"
local NUT = { "#1e1520", "#30202c", "#4a3036", "#6a4640", "#946a56", "#e6d2c0" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local BLUE = { "#2a4a7a", "#3f72c0", "#6aa6ea", "#b0daff" }

-- seeds
local seeds = { { 18, 48, 3.3, 2.3, 0.35 }, { 28, 46, 3.2, 2.3, -0.25 }, { 39, 44, 3.2, 2.2, 0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf scrap: oblong blade, tip at right, torn at the left
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 47, 56, 44, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 7.4 * sin(pi * min(1, t * 0.72 + 0.28)) ^ 0.8)
end, { fold = 0.42 })
-- ragged tear: zigzag cut through the left end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + 0.05 * ((y * 7) % 3) + 0.04 * X.hash(x, y, 11)
  if LT[k] < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 6) % 6.5
  if d < 0.9 and abs(s) > 0.18 and abs(s) < 0.75 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- rim: cool bounce on the lower edge, pale hairs along the upper edge, torn edge pale (fresh tissue)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] < 0.22 then c:put(x, y, LEAF[5], ltok)
  elseif LS[k] > 0.6 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end
end)
for _, t in ipairs{ 0.3, 0.42, 0.56, 0.7, 0.82 } do
  local best
  lm:each(function(x, y) local k = K(x, y) if abs(LT[k] - t) < 0.012 and LS[k] < -0.7 then if not best or y < best[2] then best = { x, y } end end end)
  if best and not lm:has(best[1], best[2] - 1) then c:put(best[1], best[2] - 1, HAIR, ltok) end
end

-- sprout from the right nutlet
local stok = { r = { name = "stem" } }
local sp = { { 40, 43 }, { 41, 36 }, { 38, 28 }, { 39, 16 } }
local sm, sn, ST = A.stem(c, sp, function() return 1.0 end, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, cut = seeds[3].m })
-- cotyledons: round paddles
local ctok = { r = { name = "cot" } }
local cot = HP.mask()
for _, q in ipairs{ { 34.5, 30.5, -0.35 }, { 44.5, 31, 0.3 } } do
  local m, n = A.oval(q[1], q[2], 3.3, 1.9, q[3], 0.8) m:cut(sm)
  A.shade(c, m, n, LEAF, { amb = 0.16, wrap = 0.3, tok = ctok }) cot:add(m)
end
-- true leaves: oblong-lanceolate, hairy margins
local tl = HP.mask()
local function tleaf(ax, ay, cx, cy, bx, by)
  local m, T, S = A.leaf(c, ax, ay, cx, cy, bx, by, 2.3, LEAF, { cut = sm, fold = 0.4, pw = 0.6, vs = 2.6 })
  m:edge():each(function(x, y) local k = K(x, y) if S[k] < -0.5 and T[k] > 0.2 and T[k] < 0.85 and (x + y) % 3 == 0 then c:put(x, y, HAIR, { r = { name = "leaf" } }) end end)
  tl:add(m)
end
tleaf(39, 22, 33, 20, 27, 15)
tleaf(39, 21, 46, 19, 52, 13)
-- re-tone stem bits over leaf bases (stem in front)
sm:each(function(x, y) if ST[K(x, y)] > 0.25 and ST[K(x, y)] < 0.6 and (tl:has(x, y) or cot:has(x, y)) then c:put(x, y, STEM[3], stok) end end)

-- quirk: one tiny forget-me-not flower on top (5 petals, yellow eye)
local ft = { r = { name = "flower" } }
local fx, fy = 39, 12
for _, p in ipairs{ { 0, -2 }, { 2, -1 }, { 1, 2 }, { -1, 2 }, { -2, -1 } } do
  local m = c:ellipse(fx + p[1], fy + p[2], 1.2, 1.2)
  m:each(function(x, y) local lit = (x - fx) + (y - fy) < 0 c:put(x, y, lit and BLUE[3] or BLUE[2], ft) end)
end
for _, p in ipairs{ { 0, -2 }, { -2, -1 } } do c:put(fx + p[1], fy + p[2], BLUE[4], ft) end
c:put(fx, fy, "#f8d266", ft) c:put(fx + 1, fy, "#e8a62c", ft) c:put(fx, fy + 1, "#e8a62c", ft) c:put(fx - 1, fy, "#fff0b0", ft)
-- deep between petals and stem top
c:put(fx, fy + 3, STEM[1], stok)

-- nutlets last: glossy, keeled, AO where they touch
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "nut" .. i } }
  local idx = A.shade(c, vis, s.n, NUT, { amb = 0.08, wrap = 0.2, cuts = { 0.18, 0.36, 0.56, 0.78, 0.97 }, bias = sb, tok = tok })
  -- keel: one darker ridge along the long axis on the shade half
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(v - 0.6) < 0.5 and abs(u) < s[3] - 1 then c:put(x, y, NUT[max(1, (idx[K(x, y)] or 3) - 1)], tok) end end)
  -- pointed end (teardrop) and specular
  local px, py = floor(s[1] + ca * (s[3] + 1.2) + .5), floor(s[2] + sa * (s[3] + 1.2) + .5)
  if not vis:has(px, py) then c:put(px, py, NUT[3], tok) end
  local gx, gy = floor(s[1] - 1.2 + .5), floor(s[2] - 1 + .5)
  c:put(gx, gy, NUT[6], tok) c:put(gx + 1, gy, NUT[5], tok)
end

A.save(c, NAME)
