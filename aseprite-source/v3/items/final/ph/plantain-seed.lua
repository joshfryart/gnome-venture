-- plantain-seed (final pass, Opus, aC35_2). Three hard, glossy, angular black wild-plantain seeds on a torn wedge
-- of plantain leaf: pale grooved midrib along the upper edge, parallel slanted veins, the lower margin split into
-- ribbons along the veins (the way Musa leaves tear), AO + contact shadow under each seed, cool rims on the seeds.
-- The right seed has germinated: pale stem, a short root, a paddle-shaped first leaf (blunt oblong, parallel
-- veins) and a second leaf still rolled up like a cigar beside it.
-- quirk: one round raindrop sits on the paddle leaf, with a bright rim and a pale core.
local NAME = "plantain-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local RIB  = { "#5a7536", "#7c9545", "#a2b65a", "#c3d275", "#dfe59c", "#f0f2c0" }
local SEED = { "#140e14", "#241a22", "#382a34", "#4e3e4a", "#6e5e6c", "#b2a4b4" }
local SCOOL = "#46587c"
local STEM = { "#3f7a4c", "#6aa65c", "#9ccc7c", "#cfe8a8", "#ecf6cc" }
local ROOT = { "#b49a7a", "#d8c4a0", "#f0e4c4" }
local DROP = { "#3a86b0", "#5fc4c8", "#b6f0e0", "#effcf8" }

-- leaf wedge: a slightly curved band, ends torn along the slanted vein direction
local W = 6.2
local lm, ln, LT, LS, len = A.blade(6, 47, 32, 41, 58, 46, function(t) return W end, { fold = 0.2 })
local SL = 0.9   -- vein slant (px along per px across)
local rm = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local a = t * len - s * W * SL
  if a < 3 + X.hash(floor(s * 4), 1, 2) * 2 or a > len - 4 - X.hash(floor(s * 4), 2, 2) * 2 then rm[#rm + 1] = k end
  -- ribbon tears along veins on the lower half
  local ph = (a + 2) % 11
  if s > 0.15 and ph < 0.8 and t > 0.12 and t < 0.92 then rm[#rm + 1] = k end
end)
for _, k in ipairs(rm) do lm.s[k] = nil end
-- one ribbon droops: shift the lowest strip of the second tear down 1px (just recolour the lowest edge darker)
local seeds = {
  { 15, 45, 3.0, 2.2, 0.5 }, { 25, 42, 3.2, 2.3, -0.4 }, { 40, 43, 3.1, 2.3, 0.2 },
}
for i, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6)
  -- knock off corners for angular pebble shape
  local e = s.m:edge() local cut = {}
  e:each(function(x, y) if X.hash(x, y, 17 + i) > 0.62 then cut[#cut + 1] = K(x, y) end end)
  for _, k in ipairs(cut) do s.m.s[k] = nil end
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = bias, amb = 0.16, wrap = 0.3, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 } })
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if bias[k] then return end
  if s < -0.62 then
    -- midrib: pale, grooved (lit top row, dark groove, mid row)
    local i = s < -0.86 and 4 or (s < -0.74 and 2 or 5)
    if LS[k] < -0.86 and t > 0.5 then i = 3 end
    c:put(x, y, RIB[i], ltok)
  else
    local a = t * len - s * W * SL
    if a % 3 < 0.9 then c:put(x, y, LEAF[min(6, (lidx[k] or 3) + 1)], ltok) end
  end
end)
-- shade line under midrib
lm:each(function(x, y) local k = K(x, y) if LS[k] >= -0.62 and LS[k] < -0.5 and not bias[k] then c:put(x, y, LEAF[2], ltok) end end)

-- sprout from the right seed
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 40, 41 }, { 39, 35 }, { 38, 29 }, { 38, 24 } }, function(t) return 1.0 end)
for _, s in ipairs(seeds) do sm:cut(s.m) end
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
-- root out the right side over the leaf
local rtok = { r = { name = "root" } }
for i, p in ipairs{ { 44, 45 }, { 45, 46 }, { 46, 46 }, { 47, 47 }, { 48, 48 }, { 49, 48 } } do c:put(p[1], p[2], ROOT[(i % 2 == 0) and 2 or 1], rtok) end
c:put(50, 49, ROOT[3], rtok)
-- paddle leaf: blunt oblong, parallel veins
local pbias = {}
local wfn = function(t) if t > 0.99 then return -1 end return max(0.6, 4.4 * sin(pi * min(1, t * 0.82 + 0.12)) ^ 0.35) end
local pm, pT, pS, pidx, plen = A.leaf(c, 38, 24, 30, 12, 17, 13, 4.4, LEAF, { tok = ltok, wfn = wfn, vs = 2.6, vslant = 2.2, fold = 0.35, cut = sm })
-- rolled cigar leaf, pale, standing up and right
local cm, cn, CT, CS = A.tube({ { 38, 25 }, { 39, 20 }, { 41, 16 }, { 43, 11 } }, function(t) return 1.35 - 0.6 * t end)
cm:cut(pm)
local cidx = A.shade(c, cm, cn, { "#2f7744", "#46954b", "#68b452", "#98d06a", "#c4e490", "#e6f4bc" }, { tok = stok })
cm:each(function(x, y) local k = K(x, y) if abs(CT[k] * 14 % 3.2 - CS[k] * 1.4) < 0.5 then c:put(x, y, "#46954b", stok) end end)
-- AO where leaves meet stem
for _, p in ipairs{ { 37, 25 }, { 39, 26 } } do if pm:has(p[1], p[2]) or sm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[2], stok) end end

-- seeds: glossy black pebbles with cool rim + one hard specular each
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sidx = A.shade(c, s.m, s.n, SEED, { tok = tok, amb = 0.05, wrap = 0.15, cuts = { 0.18, 0.36, 0.55, 0.72, 0.95 } })
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.35 and (sidx[k] or 1) <= 2 then c:put(x, y, SCOOL, tok) end end)
  local bx, by = A.specAt(s.m, s.n, 30)
  if bx then c:put(bx, by, "#f4eef6", tok) if s.m:has(bx + 1, by) then c:put(bx + 1, by, SEED[6], tok) end end
end
-- the sprouting seed is split: pale crack on top
for _, p in ipairs{ { 39, 41 }, { 41, 41 } } do c:put(p[1], p[2], "#8c7a84", { r = { name = "seed3" } }) end

-- quirk: raindrop on the paddle leaf
local dtok = { r = { name = "drop" } }
A.map(c, {
  ".ab.",
  "acdb",
  "abba",
  ".aa.",
}, 24, 14, { a = DROP[1], b = DROP[2], c = DROP[4], d = DROP[3] }, dtok)
-- drop shadow on the leaf
for _, p in ipairs{ { 26, 18 }, { 27, 17 }, { 27, 18 } } do if pm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[2], ltok) end end

A.save(c, NAME)
