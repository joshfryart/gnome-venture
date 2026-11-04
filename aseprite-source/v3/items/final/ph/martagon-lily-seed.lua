-- martagon-lily-seed (final, Opus single pass). Three flat papery martagon-lily seeds (thin tan discs with a paler wing
-- rim and a dark embryo streak, fanned like dropped coins) on a torn scrap of a slim lanceolate lily leaf (monocot:
-- parallel veins, V-fold light, cool shade edge, AO + contact shadow under each seed). A fourth seed has germinated the
-- lily way: a pale root, one whip-thin arching cotyledon and a first narrow lance leaf.
-- quirk: the cotyledon tip still wears the papery seed coat like a little hat.
local NAME = "martagon-lily-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aC22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#16342f", "#1f4b3a", "#2b6644", "#43844c", "#69a556", "#a0c96e" }
local VEIN, COOL = "#bfe08e", "#3b6670"
local PAP = { "#4a3426", "#6e4e32", "#93693e", "#b98a52", "#d8ae72", "#f0d49c" }
local EMB = "#5a2f2e"
local STEM = { "#5a7a48", "#8db46a", "#c0dc96", "#ecf4c6" }

-- leaf scrap: long slim lance leaf, torn at the right end
local lm, ln, LT, LS, len = A.blade(5, 50, 30, 38, 58, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.4 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.8)
end, { fold = 0.45 })
A.tear(lm, LT, LS, 0.06, 0.07, 5, true)

-- seeds: flat discs cx, cy, rx, ry, angle (lowest drawn first)
local seeds = { { 17, 44, 4.4, 3.3, 0.35 }, { 24, 42, 4.5, 3.4, -0.25 }, { 30, 45, 4.3, 3.2, 0.6 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.35) end
local sprSeed = { 40, 40, 3.6, 2.6, -0.2 }
sprSeed.m, sprSeed.n = A.oval(sprSeed[1], sprSeed[2], sprSeed[3], sprSeed[4], sprSeed[5], 0.4)

local bias = {}
for _, s in ipairs(seeds) do A.shadow(bias, lm, s.m, 1, 1) end
A.shadow(bias, lm, sprSeed.m, 1, 1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- parallel veins (monocot): midrib + two veins per side running the length
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.03 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, q in ipairs{ 0.42, 0.72 } do
    if abs(abs(s) - q) < 0.07 and t > 0.08 and t < 0.92 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.08 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- leaf base: the clasping stalk end
for _, q in ipairs{ { 4, 51, 3 }, { 3, 52, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout: root down, whip cotyledon arching up (carrying the seed coat), first lance leaf
local stok = { r = { name = "stem" } }
local root = { { 41, 42 }, { 43, 45 }, { 46, 46 }, { 49, 49 } }
local rm, rn = A.tube(root, function(t) return 0.9 * (1 - t) ^ 0.7 + 0.2 end)
rm:cut(sprSeed.m)
A.shadow(bias, lm, rm, 1, 1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not sprSeed.m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), { "#9c8a6a", "#c8b892", "#e8dcb8", "#f8f0d8" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "root" } } })
local cot = { { 40, 38 }, { 38, 28 }, { 41, 18 }, { 49, 16 } }
local cm, cn = A.tube(cot, function(t) return 0.95 - 0.35 * t end, 200)
cm:cut(sprSeed.m)
X.tone(c, cm, X.light(cn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- first true leaf: narrow lance blade up and to the left
local fm, fn, FT, FS = A.blade(39, 37, 33, 30, 29, 21, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 1.9 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
end, { fold = 0.35 })
fm:cut(sprSeed.m):cut(cm)
A.toneN(c, fm, fn, LEAF, { tok = ltok, cuts = A.CUTS6, amb = 0.16, wrap = 0.3 })
fm:each(function(x, y) local k = K(x, y) if abs(FS[k]) < 0.15 and FT[k] > 0.12 and FT[k] < 0.85 then c:put(x, y, FS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)

-- paint a papery seed (flat disc: wing rim, embryo streak, faint radial wrinkles)
local function paper(s, vis, tok, bb)
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.15, wrap = 0.35 }), PAP, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = bb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local r = sqrt(u * u + v * v)
    local i = idx[k]
    if r > 0.78 then i = i + 1 end                                   -- thin translucent wing rim, paler
    if abs(v) < 0.2 and u > -0.5 and u < 0.35 then c:put(x, y, EMB, tok) return end   -- embryo streak
    if r > 0.4 and r < 0.75 and X.hash(x, y, 9) > 0.8 then i = i - 1 end  -- papery wrinkles
    c:put(x, y, PAP[max(1, min(6, i))], tok)
  end)
end
-- quirk: the seed coat hat on the cotyledon tip
do local hx, hy = 49, 15
  local hm, hn = A.oval(hx, hy, 2.7, 1.8, -0.45, 0.4)
  local htok = { r = { name = "hat" } }
  local hb = {}
  X.tone(c, hm, X.light(hn, { amb = 0.15, wrap = 0.35 }), PAP, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, tok = htok })
  c:put(hx, hy, EMB, htok)
  c:put(hx - 1, hy - 1, PAP[6], htok)
end
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) A.shadow(sb, s.m, seeds[j].m, 1, 1) end
  paper(s, vis, { r = { name = "seed" .. i } }, sb)
end
-- the germinated seed sits over the cotyledon and leaf feet
paper(sprSeed, sprSeed.m, { r = { name = "seedS" } }, {})
-- one glint on the top seed's wing
c:put(28, 42, A.CREAM, { r = { name = "seed3" } })

A.save(c, NAME)
