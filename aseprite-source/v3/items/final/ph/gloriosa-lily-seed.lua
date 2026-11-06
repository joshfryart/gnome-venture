-- gloriosa-lily-seed (final, Opus single pass). Three round glossy flame-orange gloriosa seeds (sphere light, cream
-- specular, hilum dot, cool bounce, contact shadow) on a long lanceolate gloriosa leaf scrap torn at the base (monocot:
-- parallel veins sweeping to the tip, V-fold light, cool shade edge). The right seed sprouts a thin stem with two
-- alternate lance leaves; the top leaf ends in a gloriosa tendril.
-- quirk: that tendril has curled itself into a tidy little loop, as if reaching for a trellis that isn't there.
local NAME = "gloriosa-lily-seed"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_3.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = B.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#a4d46e" }
local VEIN, COOL = "#c4e68c", "#3a6c72"
local SEED = { "#561a2c", "#8c2430", "#c23a2c", "#e65f2c", "#fa9140", "#ffcf86" }
local STEM = { "#2e7646", "#4f9a52", "#86c06a", "#c0e294" }
local TEND = "#86c06a"
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }

-- seeds
local seeds = { { 21, 44, 3.4 }, { 30, 41, 3.4 }, { 39, 38, 3.3 } }
for _, s in ipairs(seeds) do
  s.m = c:ellipse(s[1], s[2], s[3], s[3])
  s.n = X.sphere(s[1], s[2], s[3], s.m)
end

-- leaf scrap: long lance along a gentle curve, torn at the base end
local lm, ln, LT, LS, len = B.blade(7, 53, 28, 51, 56, 33, function(t)
  if t > 0.99 then return -1 end
  return max(0.4, 6.8 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.9)
end, { fold = 0.42 })
B.tear(lm, 12, 51, -0.85, -0.5, 1.6, 4)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) B.cast(bias, lm, s.m, 1, 2, -1) end
B.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- parallel veins: midrib + two lines each side converging to the tip
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.96 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vv in ipairs{ -0.55, 0.5 } do
    if abs(s - vv) < 0.09 and t > 0.12 and t < 0.86 then c:put(x, y, vv < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn base edge: pale fibrous rim
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] and LT[k] < 0.1 and X.hash(x, y, 2) > 0.4 then c:put(x, y, LEAF[6], ltok) end end)

-- sprout stem from the right seed
local sp = { { 39, 37 }, { 38, 30 }, { 41, 23 }, { 40, 15 } }
local sm, sn = B.tube(sp, function(t) return 1.0 - 0.15 * t end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function lance(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = B.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, W * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.8)
  end, { fold = 0.35 })
  m:cut(sm)
  local ab = {}
  X.ao(ab, m, sm, 1, -1)
  B.toneN(c, m, n, LEAF, { tok = ltok, cuts = B.CUTS, amb = 0.14, wrap = 0.3, bias = ab })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.08 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
lance(38, 29, 31, 25, 23, 27, 2.6)
lance(40, 21, 46, 16, 52, 18, 2.4)
-- top leaf tip + tendril loop (quirk)
lance(40, 17, 39, 13, 35, 11, 1.8)
local tpts = { { 34, 11 }, { 32, 11 }, { 31, 10 }, { 31, 9 }, { 32, 8 }, { 33, 8 }, { 34, 9 }, { 33, 10 } }
for i, p in ipairs(tpts) do c:put(p[1], p[2], (i <= 2) and STEM[2] or TEND, stok) end

-- seeds last: glossy spheres
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = B.shade(c, vis, s.n, SEED, { amb = 0.06, wrap = 0.2, bias = sb, tok = tok, cuts = { 0.14, 0.3, 0.5, 0.7, 0.88 } })
  -- cool bounce on the lower-right rim
  vis:each(function(x, y) local nn = s.n[K(x, y)]
    if nn[1] + nn[2] > 1.05 then c:put(x, y, "#9a3a5a", tok) end end)
  -- hilum: small dark eye on the lower left
  c:put(s[1] - 1, s[2] + 2, SEED[1], tok)
  -- specular: cream pixel + hi neighbour
  c:put(s[1] - 1, s[2] - 2, B.CREAM, tok) c:put(s[1] - 2, s[2] - 1, SEED[6], tok)
end

B.save(c, NAME)
