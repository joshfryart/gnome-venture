-- orange-seed (final, Opus aC31_2 single pass). Three cream citrus pips (teardrop with a pointed beak, wrinkled coat,
-- AO between them) on a torn glossy orange-leaf scrap (elliptic, midrib + swept veins, cool reflected edge, ragged tear
-- where the tip ripped off). The right pip has germinated: pale radicle, slim green stem and two glossy elliptic
-- true leaves plus a folded bud, the citrus leaf shape in miniature.
-- quirk: a little curl of orange peel (pith side showing) lies on the leaf beside the pips.
local NAME = "orange-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)

-- seed placements (cx, cy, rx, ry, angle); beak points along -u
local P = { { 18, 47, 4.2, 2.6, 0.25 }, { 27, 49, 4.4, 2.7, -0.15 }, { 37, 46, 4.2, 2.6, 2.6 } }
local pm = {}
for i, s in ipairs(P) do pm[i] = A.pip(A.new("tmp"), s[1], s[2], s[3], s[4], s[5], A.SEED) end

-- peel curl (quirk): a rind strip rolled into a C, as a tube
local CP = { { 43, 53 }, { 51, 57 }, { 54, 47 }, { 47, 47.5 } }
local curl, cn, CT, CS = A.tube(CP, function(t) return 1.15 end)
-- leaf scrap: base at left, torn tip at the right
local bias = {}
local lmProbe = A.leaf(A.new("tmp"), 6, 50, 30, 43, 60, 47, 8.4, { spec = false })
for i = 1, 3 do X.ao(bias, lmProbe, pm[i], 1, -1) A.cast(bias, lmProbe, pm[i], 1, 2, -1) end
X.ao(bias, lmProbe, curl, 1, -1) A.cast(bias, lmProbe, curl, 1, 1, -1)
local tear = function(t, s, x, y)
  local band = floor((s + 1) * 4.5)
  local edge = 0.8 + (X.hash(band, 3, 7) - 0.5) * 0.09 - s * 0.05
  return t > edge
end
local lm, LT, LS = A.leaf(c, 6, 50, 30, 43, 60, 47, 8.4, { bias = bias, tear = tear, per = 5.2, cuts = { 0.36, 0.52, 0.66, 0.8, 0.92 } })
-- pale torn fibres along the rip
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] > 0.72 and abs(LS[k]) < 0.85 then c:put(x, y, "#b6d98a") end end)
-- petiole stub
for _, q in ipairs{ { 5, 51, 3 }, { 4, 51, 4 }, { 3, 52, 3 } } do c:put(q[1], q[2], A.LEAF[q[3]]) end

-- sprout from pip 3: radicle down-left onto the leaf, stem up
local stok = { r = { name = "stem" } }
local rm, rn = A.tube({ { 34, 47 }, { 32, 50 }, { 30, 52 }, { 28, 54 } }, function(t) return 0.95 * (1 - t) + 0.25 end)
A.shade(c, rm, rn, { "#8a7458", "#c2ad86", "#e8dbb4", "#fbf3d8" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "radicle" } } })
local sp = { { 38, 45 }, { 39, 36 }, { 36, 28 }, { 37, 17 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - 0.25 * t end)
A.shade(c, sm, sn, A.STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local l1 = A.leaf(c, 37, 29, 30, 22, 20, 22, 4.2, { per = 3.4, wing = 0.12, name = "tl1" })
local l2 = A.leaf(c, 37, 24, 44, 17, 52, 18, 4.3, { per = 3.4, wing = 0.12, name = "tl2" })
local l3 = A.leaf(c, 37, 18, 36, 13, 39, 8, 2.1, { veins = false, spec = false, name = "bud" })
sm:clip(c:rect(30, 26, 45, 60))
-- AO at the leaf joints
for _, q in ipairs{ { 36, 29 }, { 38, 24 }, { 38, 18 } } do c:put(q[1], q[2], A.STEM[1]) end

-- pips last
for i, s in ipairs(P) do
  local b = {}
  for j = i + 1, #P do X.ao(b, pm[i], pm[j], 1, -1) end
  if i == 3 then X.ao(b, pm[3], sm, 1, -1) end
  local cm = HP.mask() for j = i + 1, #P do cm:add(pm[j]) end
  A.pip(c, s[1], s[2], s[3], s[4], s[5], A.SEED, { bias = b, cutm = cm, name = "pip" .. i })
end
-- germination split on pip 3 (stem emerges from a crack)
c:put(38, 44, A.SEED[2]) c:put(39, 45, A.SEED[1])
c:put(16, 45, A.SEED[6]) c:put(17, 45, A.SEED[6])   -- glint on the front pip

-- quirk: peel curl, orange zest outside, white pith on the inner edge, zest pores
local PEEL = { "#5c1d2e", "#97302a", "#cd521f", "#ee7a1d", "#fba23a", "#ffcf78" }
local cidx = A.shade(c, curl, cn, PEEL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "peel" } } })
curl:each(function(x, y) local k = K(x, y)
  if CS[k] < -0.55 and CT[k] > 0.35 then c:put(x, y, "#f4e4c2") end
  if CS[k] < -0.55 and CT[k] > 0.82 then c:put(x, y, "#d8c3a0") end
end)
c:put(45, 52, PEEL[6]) c:put(46, 52, PEEL[6])
A.save(c, NAME)
