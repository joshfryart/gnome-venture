-- mint-seed (Opus single pass). Four tiny glossy dark-brown ovoid mint seeds on a scrap of mint leaf (ovate,
-- serrated, rugose: impressed side veins with lit ridges, pale midrib, cool bounce on the lower edge, short petiole).
-- The biggest seed has split: a slim square seedling stem rises out of it with a pair of round cotyledons and
-- the first pair of true mint leaves (serrated, veined, pointed); a pale radicle curls out the other side.
-- AO + contact shadow under every seed and under the sprout base. One cream glint per seed (glossy seed coat).
-- History: replaces the Sonnet draft (sat low-left, dots for seeds, blob leaves).
-- quirk: the seedling still wears its empty seed coat like a little cap on one cotyledon.
local NAME = "mint-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_mint.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local floor, sin, cos = math.floor, math.sin, math.cos

local LEAF = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" }
local YNG  = { "#18483f", "#246c4f", "#32905a", "#52b264", "#86d276", "#bfeb98" }
local COT  = { "#2a5a3a", "#3f7c44", "#5b9c4c", "#7fbb5a", "#a8d673", "#d2ee9e" }
local STEM = { "#2c3a3e", "#3f5450", "#5a745c", "#7c966c", "#a6bc88" }
local SEED = { "#22141a", "#371d1f", "#512a24", "#6f3c2b", "#925636", "#b97c4c" }
local COOL, GLINT, ROOT, ROOTS = "#3d7a86", "#fff2d8", "#f4ecd6", "#c9bda8"

-- leaf scrap: base lower-left, tip upper-right, gently arched
local L = G.mintGeom(11, 54, 30, 41, 55, 41, 8.2, { tooth = 3.6, tcut = 0.25, exp = 0.75, fold = 0.32 })

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 19, 48, 2.8, 1.7, 0.5 }, { 25.5, 51, 2.6, 1.6, -0.3 }, { 31, 46.5, 3.1, 2.0, 0.2 }, { 23.5, 44, 2.5, 1.5, 1.1 } }
for _, s in ipairs(seeds) do
  s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 1)
end
-- sprout geometry (out of seed 3)
local stem, sn, ST, SS = G.tube({ { 31, 45 }, { 31.5, 36 }, { 30, 27 }, { 31, 18 } }, function(t) return 1.05 - t * 0.2 end)
local cotL, cotLn = G.oval(25, 27.5, 4.0, 2.6, -0.35, 1)
local cotR, cotRn = G.oval(36.5, 27, 4.0, 2.6, 0.3, 1)
local tl = G.mintGeom(30.5, 18, 26, 13, 21, 11, 3.4, { tooth = 2.9, tcut = 0.3, fold = 0.42 })
local tr = G.mintGeom(31.5, 18, 36, 12, 41, 9, 3.3, { tooth = 2.9, tcut = 0.3, fold = 0.42 })
local tip, tipn = G.oval(31, 16.5, 1.4, 1.6, 0, 1)

-- leaf scrap with AO + contact shadow from seeds and sprout base
local lb = {}
for _, s in ipairs(seeds) do X.ao(lb, L.m, s.m, 1, -1) G.cast(lb, L.m, s.m, 1, 1, -1) G.cast(lb, L.m, s.m, 2, 2, -1) end
G.cast(lb, L.m, stem, 1, 1, -1)
G.mintPaint(c, L, LEAF, lb, { cool = COOL, slant = 5, veins = { 0.2, 0.36, 0.52, 0.68, 0.82 }, name = "scrap" })
-- petiole stub
local ptok = { r = { name = "pet" } }
for _, p in ipairs{ { 8, 57, 3 }, { 9, 56, 4 }, { 10, 55, 4 }, { 9, 57, 2 }, { 10, 56, 2 } } do
  if not L.m:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[p[3]], ptok) end
end

-- radicle: pale curl out of the lower-right of seed 3
local rtok = { r = { name = "root" } }
for _, p in ipairs{ { 35, 48, ROOT }, { 35, 49, ROOT }, { 36, 50, ROOT }, { 37, 51, ROOTS }, { 38, 51, ROOTS }, { 39, 50, ROOTS }, { 39, 49, ROOTS }, { 36, 49, ROOT } } do c:put(p[1], p[2], p[3], rtok) end

-- seedling stem (in front of the scrap, behind the seed)
local stok = { r = { name = "stem" } }
local sb = {}
local leafy = cotL:copy():add(cotR):add(tl.m):add(tr.m):add(tip)
stem:cut(leafy)
X.ao(sb, stem, leafy, 1, -1)
G.toneN(c, stem, sn, STEM, { bias = sb, tok = stok, cuts = { 0.25, 0.45, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })

-- seeds, back to front (by y)
table.sort(seeds, function(a, b) return a[2] < b[2] end)
for i, s in ipairs(seeds) do
  local b = {}
  for j = i + 1, #seeds do X.ao(b, s.m, seeds[j].m, 1, -1) end
  local vis = s.m:copy()
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.08, wrap = 0.2 })
  local vv = {}
  for k, x in pairs(v) do vv[k] = x end
  X.tone(c, vis, vv, SEED, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = b, tok = tok })
  -- hilum: a dark dimple on the lower-right end
  local hx = floor(s[1] + cos(s[5]) * (s[3] - 1) + .5)
  local hy = floor(s[2] + sin(s[5]) * (s[3] - 1) + .5)
  if vis:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  local gx, gy = G.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, GLINT, tok) end
end

-- cotyledons: smooth, round, paler
for _, cd in ipairs{ { cotL, cotLn }, { cotR, cotRn } } do
  local b = {}
  X.ao(b, cd[1], stem, 1, -1)
  G.toneN(c, cd[1], cd[2], COT, { bias = b, tok = { r = { name = "cot" } }, cuts = { 0.2, 0.38, 0.55, 0.72, 0.86 } })
end
-- true leaves + growing tip
G.mintPaint(c, tl, YNG, nil, { veins = { 0.36, 0.62 }, slant = 2, name = "tl" })
G.mintPaint(c, tr, YNG, nil, { veins = { 0.36, 0.62 }, slant = 2, name = "tr", cool = COOL })
G.toneN(c, tip, tipn, YNG, { cuts = { 0.3, 0.5, 0.7, 0.85, 0.95 } })

-- quirk: empty seed coat cap on the right cotyledon tip (open side down)
local capm, capn = G.oval(40.6, 27.6, 2.6, 2.0, 0.3, 1)
local ctok = { r = { name = "cap" } }
G.toneN(c, capm, capn, SEED, { tok = ctok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- open lip where the cotyledon goes in: a split ring in the pale inner-coat tone
for _, p in ipairs{ { 38, 27 }, { 38, 28 }, { 39, 26 } } do c:put(p[1], p[2], SEED[5], ctok) end
c:put(39, 29, SEED[1], ctok)
local gx, gy = G.specAt(capm, capn, 30)
if gx then c:put(gx, gy, GLINT, ctok) end
G.shift(c, 0, -2)
G.save(c, NAME)
