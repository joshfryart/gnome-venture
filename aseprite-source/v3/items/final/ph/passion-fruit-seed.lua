-- passion-fruit-seed (aC32_2 final, Opus single pass). Three flat, ovate passion-fruit seeds (near-black brown, pitted
-- honeycomb coat, one glint) on a torn scrap of a glossy passion-fruit leaf lobe (serrate margin, midrib + swept veins,
-- V-fold light, cool reflected edge, AO + contact shadow under each seed). The right seed stands on end and has split:
-- pale stem, two oval cotyledons, a first three-lobed true leaf (the passion-fruit leaf shape) and a coiled tendril.
-- quirk: the left seed is still wrapped in its golden jelly aril, like it was just scooped from the fruit.
local NAME = "passion-fruit-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local full = c:rect(0, 0, 63, 63)
local LEAF = { "#143630", "#1d553d", "#2a7444", "#43944b", "#69b656", "#a3d672" }
local SEED = { "#1c121c", "#2e1d26", "#47292c", "#643c33", "#86573f", "#b2845c" }
local SEEDJ = { "#5a2a1c", "#74381e", "#8e4c22", "#a8622a", "#c47c34", "#e09c48" }
local ARIL = { "#8a4418", "#c0661a", "#e6901e", "#f7b52c", "#ffd658", "#fff0a4" }
local STEM = { "#3c744a", "#68a65a", "#9ccf78", "#d4eeaa" }
local COOL = "#3a6c72"

-- seeds: cx, cy, rx, ry, angle
local S1 = { 16, 44, 4.3, 2.9, -0.35 }
local S2 = { 28, 47, 4.4, 3.0, 0.12 }
local S3 = { 41, 43, 4.2, 2.8, -1.25 }
local aril = A.oval(S1[1], S1[2], 6.6, 4.9, S1[5], 1.0)
local m2 = A.oval(S2[1], S2[2], S2[3], S2[4], S2[5], 0.8)
local m3 = A.oval(S3[1], S3[2], S3[3], S3[4], S3[5], 0.8)
local onLeaf = aril:copy():add(m2):add(m3)

-- leaf scrap: one lobe of a passion-fruit leaf, torn across on the right
local bias = {}
X.ao(bias, full, onLeaf, 1, -1)
A.cast(bias, full, onLeaf, 1, 2, -1)
local tearM = A.tear(full:copy(), 50, 45, 0.96, -0.28, 1.9, 5)
local ltok = { r = { name = "leaf" } }
local lm, LT, LS, lidx = A.leaf(c, 7, 53, 30, 39, 57, 46, 8.6, LEAF, { cut = tearM, bias = bias, tok = ltok, vs = 4.2, fold = 0.42,
  wfn = function(t) if t > 0.985 then return -1 end return max(0.5, 8.6 * sin(pi * min(1, t * 0.95 + 0.06)) ^ 0.6) end })
-- serrate margin: a 1 px nick every few px along both edges
lm:edge():each(function(x, y) local k = K(x, y)
  if abs(LS[k]) > 0.8 and LT[k] > 0.12 and LT[k] < 0.8 and floor(LT[k] * 58 + (LS[k] > 0 and 2 or 0)) % 5 == 0 then
    A.erase(c, x, y) lm.s[k] = nil end end)
-- cool reflected light on the lower edge, pale lit rim on the torn edge
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.82 then c:put(x, y, COOL, ltok) end
  if tearM:has(x + 1, y) and LS[k] < 0.5 then c:put(x, y, LEAF[5], ltok) end end)
-- petiole stub at the base
for _, q in ipairs{ { 6, 54, 4 }, { 5, 55, 3 }, { 4, 56, 3 }, { 6, 55, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout stem (drawn before seed 3 so the split coat sits over its foot)
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 41, 42 }, { 40, 35 }, { 38, 28 }, { 38, 21 } }, function(t) return 1.05 end, STEM, { tok = stok })
-- tendril from a node on the stem, reaching right and coiling
local ttok = { r = { name = "tendril" } }
for _, p in ipairs{ { 40, 31 }, { 41, 30 }, { 42, 30 }, { 43, 29 }, { 44, 29 }, { 45, 28 } } do c:put(p[1], p[2], STEM[3], ttok) end
local sp = A.spiral(48, 30, pi * 1.15, 3.2, -0.11, 24, 1)
for i, p in ipairs(sp) do c:put(p[1], p[2], (p[2] > 30) and STEM[2] or STEM[3], ttok) end

-- cotyledons: two oval seed leaves
local ctok = { r = { name = "cotyledon" } }
local cl = A.leaf(c, 37, 22, 32, 18, 26, 20, 2.7, LEAF, { tok = ctok, vs = 9, fold = 0.3, pw = 0.55 })
local cr = A.leaf(c, 39, 22, 44, 18, 50, 20, 2.7, LEAF, { tok = ctok, vs = 9, fold = 0.3, pw = 0.55 })
-- first true leaf: petiole + three pointed lobes (the passion-fruit leaf in miniature)
for y = 17, 21 do c:put(38, y, STEM[3], stok) c:put(39, y, STEM[1], stok) end
local tl = A.leaf(c, 37, 16, 32, 13, 30, 9, 2.4, LEAF, { tok = ctok, vs = 9, fold = 0.35 })
local tr = A.leaf(c, 39, 16, 44, 13, 46, 9, 2.4, LEAF, { tok = ctok, vs = 9, fold = 0.35 })
local tc = A.leaf(c, 38, 17, 38, 12, 38, 6, 2.8, LEAF, { tok = ctok, vs = 9, fold = 0.4 })
-- dark notch where the lobes meet
for _, p in ipairs{ { 36, 15 }, { 40, 15 } } do if tc:has(p[1], p[2]) or tl:has(p[1], p[2]) or tr:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ctok) end end
-- AO under the cotyledons where they meet the stem
for _, p in ipairs{ { 37, 23 }, { 39, 23 } } do c:put(p[1], p[2], STEM[1], stok) end

-- seed 2: plain pitted seed
local b2 = {}
A.seed(c, S2[1], S2[2], S2[3], S2[4], S2[5], SEED, { pits = 0.3, pitSeed = 11, tok = { r = { name = "seed2" } } })
-- seed 3: standing seed, split at the top where the stem comes out
local t3 = { r = { name = "seed3" } }
local m3b = A.seed(c, S3[1], S3[2], S3[3], S3[4], S3[5], SEED, { pits = 0.3, pitSeed = 23, tok = t3 })
for _, p in ipairs{ { 40, 39 }, { 41, 39 }, { 41, 40 } } do c:put(p[1], p[2], STEM[2], stok) end
c:put(42, 39, SEED[5], t3)

-- seed 1 in its aril: golden jelly sac, the dark seed glowing through, glossy glints
local atok = { r = { name = "aril" } }
local an = A.body(aril, S1[1] - 0.6, S1[2] - 0.8, 5.6, 3, 0.7)
local aidx = A.shade(c, aril, an, ARIL, { amb = 0.18, wrap = 0.35, tok = atok })
local inner = A.oval(S1[1] + 0.4, S1[2] + 0.3, S1[3], S1[4], S1[5], 0.8)
local jn = select(2, A.oval(S1[1] + 0.4, S1[2] + 0.3, S1[3], S1[4], S1[5], 0.8))
local sidx = A.shade(c, inner, jn, SEEDJ, { amb = 0.15, wrap = 0.3, tok = atok })
-- a ring of bright jelly around the seed on the lit side
inner:grow(1):cut(inner):each(function(x, y) if aril:has(x, y) and (x - S1[1]) + (y - S1[2]) < -1 then c:put(x, y, ARIL[5], atok) end end)
-- glints: one big spec + a small one (glossy jelly)
c:put(12, 41, A.CREAM, atok) c:put(13, 41, A.CREAM, atok) c:put(12, 42, ARIL[6], atok)
c:put(19, 47, ARIL[6], atok)
-- a drip of jelly onto the leaf
for _, p in ipairs{ { 18, 49, 4 }, { 18, 50, 3 }, { 19, 50, 2 } } do c:put(p[1], p[2], ARIL[p[3]], atok) end

A.save(c, NAME)
