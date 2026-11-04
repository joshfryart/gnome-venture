-- cloudberry-seed (final, Opus single pass). Small tan cloudberry seeds (plump D-shaped ovals, net-pitted coat, a
-- ridge with a pale lit lip, AO and contact shadow) on a torn scrap of cloudberry leaf lying flat: round five-lobed
-- blade seen at a low angle, crinkled between palmate veins, toothed rim, right side ripped off with pale torn tissue.
-- The middle seed has sprouted: slim pale stem, two oval cotyledons and a first true leaf that is a tiny crinkly
-- kidney-shaped cloudberry leaf.
-- quirk: one seed is still sealed inside a single glossy amber drupelet that has rolled onto the leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local NAME = "cloudberry-seed"
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, TORN, COOL = "#b9dc86", "#d4e8a2", "#3a6c72"
local SEED = { "#3e2622", "#6a4230", "#94643c", "#bc8c52", "#dcb478", "#f4d8a0" }
local AMB  = { "#6a2421", "#a63f1d", "#d4691c", "#ef9628", "#fbbf47", "#ffe28e" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }

-- leaf scrap
local ltok = A.tok("leaf")
local lm, ln, vein, LA, LR = A.palmLeaf(30, 47, 21, 8.5, 2.2, 5, { R = 3 })
-- rip off the right side along a jagged line
local cut = HP.mask()
lm:each(function(x, y) if x > 44 + floor(X.hash(0, y, 21) * 3) + floor((y - 47) * 0.4) then cut:set(x, y) end end)
lm:cut(cut)
local tornE = A.tear(lm, function(x, y) return x > 41 + (y - 47) * 0.4 end, 6, true)

local seeds = { { 16, 45, 2.7, 1.9, 0.2 }, { 24, 50, 2.6, 1.9, -0.3 }, { 37, 50, 2.7, 1.9, 0.35 }, { 30, 44, 2.6, 2.0, -0.15 } }
for _, s in ipairs(seeds) do s.m, s.n = A.ell(s[1], s[2], s[3], s[4], s[5]) end
-- quirk drupelet
local dm, dn = A.ell(43, 45, 3.2, 3.0)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
X.ao(bias, lm, dm, 1, -1) A.cast(bias, lm, dm, 1, 2, -1)
lm:each(function(x, y) local k = K(x, y) if LR[k] and LR[k] < 0.15 then bias[k] = (bias[k] or 0) - 1 end end)
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.14, wrap = 0.3 })
vein:each(function(x, y) local k = K(x, y) if lm:has(x, y) and not bias[k] then c:put(x, y, (lidx[k] or 3) >= 4 and VEIN or LEAF[2], ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if tornE:has(x, y) then return end
  if X.hash(x, y, 13) < 0.22 then c:put(x, y, LEAF[2], ltok)
  elseif ln[k] and ln[k][1] + ln[k][2] > 0.45 and not bias[k] then c:put(x, y, COOL, ltok) end end)
tornE:each(function(x, y) c:put(x, y, (X.hash(x, y, 4) < 0.55) and TORN or LEAF[5], ltok) end)
-- petiole stub at the notch
local nx, ny = floor(30 + cos(2.2) * 21 * 0.78 + .5), floor(47 + sin(2.2) * 8.5 * 0.78 + .5)
for i = 0, 3 do c:put(nx - i, ny + floor(i / 2), i < 2 and LEAF[3] or LEAF[4], ltok) end

-- sprout from seed 4: stem, cotyledons, first true leaf
local stok = A.tok("sprout")
local sp = { { 30, 43 }, { 29, 35 }, { 31, 28 }, { 31, 21 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local function coty(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.4, 2.3 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.6) end, { fold = 0.3 })
  m:cut(sm)
  A.shade(c, m, n, LEAF, { tok = stok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], stok) end end)
  return m
end
local c1 = coty(30, 27, 25, 25, 20, 27)
local c2 = coty(32, 27, 37, 25, 42, 26)
-- true leaf: tiny kidney cloudberry leaf on a short petiole
A.stroke(c, { { 31, 22 }, { 31, 20 }, { 32, 18 }, { 32, 17 } }, function(t) return t < 0.5 and STEM[2] or STEM[3] end, stok, 10)
local tm, tn, tv, TA, TR = A.palmLeaf(32, 12, 6.8, 5.3, pi / 2, 5, { R = 2 })
local tb = {}
tm:each(function(x, y) local k = K(x, y) if TR[k] < 0.25 then tb[k] = -1 end end)
local tidx = A.shade(c, tm, tn, LEAF, { tok = stok, bias = tb, amb = 0.14, wrap = 0.3 })
tv:each(function(x, y) local k = K(x, y) c:put(x, y, (tidx[k] or 3) >= 4 and VEIN or LEAF[2], stok) end)
tm:edge():each(function(x, y) if X.hash(x, y, 17) < 0.2 then c:put(x, y, LEAF[2], stok) end end)

-- seeds: net-pitted coat, keel ridge with a lit lip
for i, s in ipairs(seeds) do
  local tok = A.tok("seed" .. i)
  local vis = s.m:copy()
  if i == 4 then vis:cut(sm) end
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, amb = 0.06, wrap = 0.2 })
  vis:each(function(x, y) local k = K(x, y)
    if (x + 2 * y) % 3 == 0 and X.hash(x, y, i) < 0.5 and (idx[k] or 1) >= 3 then c:put(x, y, SEED[(idx[k] or 3) - 1], tok) end end)
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) end
end
-- base of the stem sheathed by the split seed coat
c:put(30, 42, SEED[2], A.tok("seed4")) c:put(29, 42, SEED[4], A.tok("seed4"))

-- quirk: glossy amber drupelet with the seed inside (a dark seed shadow seen through the flesh)
local dtok = A.tok("drupe")
local didx = A.shade(c, dm, dn, AMB, { tok = dtok, amb = 0.06, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
for _, p in ipairs{ { 44, 46 }, { 45, 46 }, { 44, 47 } } do c:put(p[1], p[2], AMB[2], dtok) end
c:put(42, 43, A.CREAM, dtok) c:put(43, 43, AMB[6], dtok)
-- dried pistil hair on top
c:put(44, 41, AMB[2], dtok) c:put(44, 42, AMB[3], dtok)

A.save(c, NAME)
