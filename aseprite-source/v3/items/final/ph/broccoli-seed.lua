-- broccoli-seed (final, Opus single pass). Three tiny round brassica seeds (glossy red-brown, fine pitted coat,
-- one specular each, cool bounce) on a torn scrap of glaucous broccoli leaf (wavy margin, ragged torn end,
-- pale midrib + side veins, waxy bloom flecks on the lit half, AO + contact shadow under each seed).
-- The right seed has germinated: a pale purple hypocotyl (as broccoli sprouts have), two notched kidney-shaped
-- cotyledons and a first true leaf with a wavy blue-green margin and pale veins (the broccoli leaf shape).
-- quirk: the split seed coat is still stuck on the tip of the right cotyledon like a little cap.
local NAME = "broccoli-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1a3739", "#26524d", "#35705f", "#4f8f74", "#78b18d", "#acd2ad" }
local VEIN, BLOOM, COOL = "#cfe6c4", "#9cc8bf", "#35666e"
local SEED = { "#2c1520", "#4b2027", "#70312d", "#964734", "#bc6a45", "#e09a68" }
local STEM = { "#4b3a63", "#76608f", "#a38dbb", "#d2c4df" }
local SPEC = "#fff1d8"

local seeds = { { 17, 47, 2.6 }, { 26, 49, 2.6 }, { 39, 44, 2.7 } }
for _, s in ipairs(seeds) do s.m = HP.ellipse(s[1], s[2], s[3], s[3]) s.n = X.sphere(s[1], s[2], s[3], s.m) end

-- leaf scrap on the diagonal, wavy margin, torn far end
local lm, ln, LT, LS, len = A.blade(7, 52, 28, 52, 54, 41, function(t)
  local u = min(1, t * 0.95 + 0.05)
  local w = 8.2 * sin(pi * u ^ 1.05) ^ 0.55
  return max(0.6, w + 0.7 * sin(t * 50 / 3.1))
end, { fold = 0.36 })
-- ragged tear across the right end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local lim = 0.8 + 0.05 * ((floor((s + 1) * 4.5)) % 2) + 0.03 * s
  if LT[k] > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- a bite-like tear notch in the upper margin
lm:cut(HP.ellipse(22, 43, 2.2, 1.6))
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.84 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  -- side veins swept toward the tip, every ~6 px
  local ph = (t * len - abs(s) * 4.5) / 6 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.75 and t > 0.06 and t < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) return end
  -- waxy bloom flecks on the lit half
  if s < -0.2 and (lidx[k] or 0) >= 4 and A.hash(x, y, 11) > 0.84 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.78 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale exposed fibres along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] > 0.76 and not bias[k] then c:put(x, y, LEAF[5], ltok) end end)
-- petiole stub
for _, q in ipairs{ { 6, 53, 4 }, { 5, 54, 3 }, { 4, 55, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout: hypocotyl from the right seed
local stok = { r = { name = "stem" } }
local sp = { { 39, 43 }, { 38, 37 }, { 37, 31 }, { 38, 25 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
-- contact shadow of the stem on the leaf
sm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not sm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- cotyledons: kidney-shaped with a notch at the outer end
local ctok = { r = { name = "cot" } }
local function cot(cx, cy, ang, dir)
  local ux, uy = cos(ang), sin(ang)
  local m = A.rell(cx, cy, ux, uy, 5.0, 3.3)
  m:cut(HP.ellipse(cx + ux * 5.2 * dir, cy + uy * 5.2 * dir - 0.4, 1.3, 1.3))
  local n = X.pillow(m, 2.2)
  A.shade(c, m, n, LEAF, { tok = ctok, amb = 0.14, wrap = 0.3 })
  -- pale midvein
  for i = 1, 3 do local x, y = floor(cx - ux * dir * (2 - i) + .5), floor(cy - uy * dir * (2 - i) + .5)
    if m:has(x, y) then c:put(x, y, LEAF[6], ctok) end end
  return m
end
local cl = cot(32, 22, -0.25, -1)
local cr = cot(45, 21, 0.2, 1)
-- petioles from the stem top
for _, q in ipairs{ { 37, 24, 3 }, { 36, 23, 3 }, { 39, 24, 3 }, { 40, 23, 3 } } do c:put(q[1], q[2], STEM[q[3]], stok) end

-- first true leaf: oblong, wavy blue-green margin, pale veins
local tm, tn, TT, TS = A.blade(38, 24, 36, 17, 40, 9, function(t)
  if t > 0.98 then return -1 end
  local w = 3.0 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6
  return max(0.4, w + 0.45 * sin(t * 18))
end, { fold = 0.45 })
local tb = {}
X.ao(tb, tm, cl, 1, -1) X.ao(tb, tm, cr, 1, -1)
A.shade(c, tm, tn, LEAF, { tok = ltok, bias = tb, amb = 0.12, wrap = 0.28 })
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.17 and TT[k] > 0.08 and TT[k] < 0.86 then c:put(x, y, TS[k] <= 0 and VEIN or LEAF[4], ltok) end end)
c:put(36, 15, LEAF[6], ltok) c:put(40, 16, LEAF[3], ltok)

-- seeds
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.08, wrap = 0.2 })
  local sb = {}
  s.m:each(function(x, y) if A.hash(x, y, 5) > 0.8 then sb[K(x, y)] = -1 end end)
  X.tone(c, s.m, v, SEED, { cuts = { 0.15, 0.3, 0.48, 0.66, 0.82 }, bias = sb, tok = tok })
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if rim[K(x, y)] > 0.75 then c:put(x, y, "#7a3a4c", tok) end end)
  c:put(s[1] - 1, s[2] - 1, SPEC, tok)
end
-- split coat on the sprouting seed: a pale seam where it opened
c:put(39, 42, SEED[6], { r = { name = "seed3" } }) c:put(40, 42, SEED[2], { r = { name = "seed3" } })

-- quirk: the seed-coat cap on the right cotyledon tip
local cap = { "..ab.", ".abcc", "abcdd" }
A.map(c, 48, 18, cap, { a = SEED[5], b = SEED[4], c = SEED[3], d = SEED[2] }, { r = { name = "cap" } })
c:put(50, 18, SPEC)
A.save(c, NAME)
