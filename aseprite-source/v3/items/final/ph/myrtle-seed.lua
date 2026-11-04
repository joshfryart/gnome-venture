-- myrtle-seed (final, Opus single pass). Three pale kidney-shaped myrtle seeds (ivory, dark hilum in the notch) and
-- one blue-black myrtle berry with a waxy bloom and a tiny crown, on a torn glossy myrtle leaf (lanceolate, dark,
-- midrib, faint veins, translucent oil-gland dots, specular streak, cool edge). The middle seed has sprouted into a
-- thin upright seedling with pairs of opposite, pointed little myrtle leaves.
-- quirk: the seedling has (far too early) opened a single white myrtle blossom with a burst of gold stamens.
local NAME = "myrtle-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF  = { "#122e2a", "#1c4434", "#285e3c", "#3a7a44", "#5c9a52", "#94c27a" }
local SPR   = { "#1e4a34", "#2e6a3e", "#4a8c48", "#6eae56", "#9ccc6e", "#cce79a" }
local IVORY = { "#5a3e2c", "#86603e", "#b08a58", "#d0ae78", "#e8d0a0", "#f8ecc8" }
local BERRY = { "#1a1430", "#262048", "#36306a", "#4a4690", "#6c6cb0", "#a0a8d8" }
local STEM  = { "#4a3a2a", "#6e5a3a", "#94804e", "#b8a86a" }
local GLAND, COOL, BLOOM = "#8cc07a", "#3c6a7a", "#7a80b4"

-- seeds: cx, cy, angle (kidney); seed 2 sprouts
local seeds = { { 16, 48, -0.25 }, { 26, 45, -0.35 }, { 34, 44, -0.1 } }
for _, s in ipairs(seeds) do
  local ca, sa = cos(s[3]), sin(s[3])
  local m, n = A.oval(s[1], s[2], 3.3, 2.2, s[3], 0.8)
  -- kidney notch on the lower edge
  local nx, ny = s[1] + sa * 2.6, s[2] + ca * 2.6
  m:cut(HP.ellipse(nx, ny, 1.0, 1.0))
  s.m, s.n, s.nx, s.ny = m, n, floor(nx + .5), floor(ny - 1 + .5)
end
local BX, BY, BR = 44, 39, 4.6
local berry = HP.ellipse(BX, BY, BR, BR)
local onleaf = HP.mask() for _, s in ipairs(seeds) do onleaf:add(s.m) end onleaf:add(berry)

-- leaf scrap: torn lanceolate myrtle leaf rising to the right
local lm, ln, LT, LS, len = A.blade(8, 52, 30, 48, 56, 35, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 7.2 * sin(pi * min(1, 0.32 + t * 0.7)) ^ 0.85)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.04 + 0.07 * X.hash(floor((x + y) / 2), 3, 1) then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, berry, 1, -1) A.cast(bias, lm, berry, 1, 2, -1) A.cast(bias, lm, berry, 2, 2, -1)
local ltok = { r = { name = "leaf" } }
local li = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 3.0) / 4.5
  if ph - floor(ph) < 0.12 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.06 and t < 0.88 then A.at(c, x, y, LEAF, li[k] + (s < 0 and 1 or -1), ltok) return end
  -- translucent oil glands
  if X.hash(x, y, 13) > 0.93 and li[k] >= 2 and li[k] <= 4 and abs(s) > 0.2 then c:put(x, y, GLAND, ltok) end
end)
-- glossy specular streak on the lit half + cool reflected edge
lm:each(function(x, y) local k = K(x, y)
  if LS[k] > -0.6 and LS[k] < -0.42 and LT[k] > 0.42 and LT[k] < 0.62 and not bias[k] then c:put(x, y, LEAF[6], ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- seedling from seed 2: thin stem with opposite leaf pairs
local SX, SY = seeds[2][1], seeds[2][2]
local spts = { { SX, SY - 1 }, { SX - 1, 35 }, { SX + 1, 24 }, { SX, 16 } }
local sm, sn = A.tube(spts, function(t) return 0.9 end)
local stok = { r = { name = "stem" } }
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local ptok = { r = { name = "sprout" } }
local function pair(t, L, w)
  local x, y = A.bez(spts, t)
  for _, d in ipairs{ -1, 1 } do
    local ax, ay = x + d * 0.8, y
    local bx, by = x + d * L * 0.9, y - L * 0.55
    local m, n, T, S = A.blade(ax, ay, (ax + bx) / 2, (ay + by) / 2 + 0.6, bx, by, function(tt)
      if tt > 0.97 then return -1 end
      return max(0.35, w * sin(pi * min(1, tt * 0.92 + 0.06)) ^ 0.7)
    end, { fold = 0.35 })
    m:cut(sm)
    local idx = A.shade(c, m, n, SPR, { tok = ptok, amb = 0.14, wrap = 0.3 })
    m:each(function(xx, yy) local k = K(xx, yy)
      if abs(S[k]) < 0.16 and T[k] > 0.1 and T[k] < 0.8 then A.at(c, xx, yy, SPR, (idx[k] or 3) + (S[k] <= 0 and 1 or -1), ptok) end end)
  end
end
pair(0.38, 9.5, 2.0)
pair(0.68, 8.0, 1.7)
pair(0.9, 5.5, 1.3)

-- seeds: ivory kidneys, dark hilum in the notch, AO between
for i, s in ipairs(seeds) do
  local tk = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, IVORY, { tok = tk, amb = 0.08, wrap = 0.2, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 } })
  c:put(s.nx, s.ny, IVORY[1], tk)
  -- faint surface wrinkle line along the back
  local ca, sa = cos(s[3]), sin(s[3])
  for u = -1, 1 do local x, y = floor(s[1] + u * ca + sa * 0.2 + .5), floor(s[2] + u * sa - 0.8 + .5)
    if s.m:has(x, y) and idx[K(x, y)] and idx[K(x, y)] >= 4 then A.at(c, x, y, IVORY, idx[K(x, y)] - 1, tk) end end
end
-- stem emerges through the sprouting seed's split coat
c:put(SX, SY - 2, STEM[3], stok) c:put(SX, SY - 1, STEM[2], stok)
c:put(seeds[1][1] - 2, seeds[1][2] - 1, IVORY[6], { r = { name = "g" } })

-- berry: blue-black, waxy bloom, glossy spec, tiny crown of calyx points at the top right
local btok = { r = { name = "berry" } }
local bn = X.sphere(BX - 0.4, BY - 0.4, BR, berry)
local bi = A.shade(c, berry, bn, BERRY, { tok = btok, amb = 0.05, wrap = 0.2, cuts = { 0.14, 0.3, 0.48, 0.66, 0.85 } })
berry:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 31) > 0.8 and bi[k] >= 2 and bi[k] <= 4 then c:put(x, y, BLOOM, btok) end end)
local br = X.rim(bn)
berry:edge():each(function(x, y) if br[K(x, y)] > 0.6 then c:put(x, y, "#4a5a8a", btok) end end)
c:put(BX - 2, BY - 2, A.CREAM, btok) c:put(BX - 1, BY - 2, BERRY[6], btok) c:put(BX - 2, BY - 1, BERRY[6], btok)
for _, q in ipairs{ { 2, -4, 1 }, { 3, -5, 2 }, { 4, -4, 1 }, { 3, -3, 1 }, { 5, -5, 3 } } do c:put(BX + q[1], BY + q[2], BERRY[q[3]], btok) end

-- quirk: a single white blossom with gold stamens on the seedling's tip
local fx, fy = A.bez(spts, 1) fx, fy = floor(fx + .5), floor(fy - 3 + .5)
local ftok = { r = { name = "flower" } }
local PET = { "#d8cfe0", "#f2ecf0", "#fff4d6" }
for _, q in ipairs{ { -2, 0 }, { -2, -1 }, { -1, -2 }, { 0, -2 }, { 2, -1 }, { 2, 0 }, { 1, 2 }, { 0, 2 }, { -1, 2 }, { 1, -2 }, { -2, 1 }, { 2, 1 } } do
  c:put(fx + q[1], fy + q[2], (q[1] + q[2] < 0) and PET[3] or ((q[1] + q[2] > 1) and PET[1] or PET[2]), ftok)
end
for _, q in ipairs{ { -1, -1 }, { 0, -1 }, { 1, -1 }, { -1, 0 }, { 0, 0 }, { 1, 0 }, { -1, 1 }, { 0, 1 }, { 1, 1 } } do
  c:put(fx + q[1], fy + q[2], (q[1] == 0 and q[2] == 0) and "#c27a2a" or "#f5c840", ftok)
end
-- stamen tips poking past the petals
for _, q in ipairs{ { 0, -3 }, { -3, -1 }, { 3, -1 }, { 3, 1 } } do c:put(fx + q[1], fy + q[2], "#f5b82e", ftok) end
c:put(fx, fy + 3, STEM[2], stok)

A.save(c, NAME)
