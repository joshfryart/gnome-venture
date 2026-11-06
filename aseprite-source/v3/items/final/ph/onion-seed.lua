-- onion-seed (final pass, Opus aC31_1). Three small black, angular, wrinkled onion seeds (one flat facet each, glossy
-- glint) on a torn scrap of blue-green onion leaf (flattened hollow strap: parallel veins, waxy pale bloom along the
-- fold, ragged torn ends, cool reflected lower edge, AO + contact shadow under each seed). The right seed has
-- germinated: blanched white foot, a thin tubular green leaf bent over in the onion "crook", a wisp of white root.
-- quirk: the crook still wears the empty black seed coat on its tip like a little hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "onion-seed"
local c = A.new(NAME)
local OL = { "#173a3e", "#24564e", "#35745c", "#4f9268", "#7cb682", "#b0d8a8" }
local BLOOM, COOL = "#d4ecd6", "#3a6a80"
local SEED = { "#16121e", "#241e30", "#352d44", "#4d4560", "#6e6888", "#a6a2c4" }
local STEM = { "#2f6a4a", "#4f9a5a", "#86c46c", "#c4e6a0", "#eef6d2" }
local GLINT = "#e8e6f6"

-- seeds: cx, cy, rx, ry, angle, facet angle
local seeds = { { 17, 46, 3.6, 2.6, 0.3, 2.2 }, { 27, 44, 3.4, 2.5, -0.5, -0.9 }, { 41, 41, 3.5, 2.6, 0.15, 1.0 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9)
  local fx, fy = cos(s[6]), sin(s[6])
  local cut = {}
  s.m:each(function(x, y) if (x - s[1]) * fx + (y - s[2]) * fy > 1.6 then cut[#cut + 1] = K(x, y) end end)
  for _, k in ipairs(cut) do s.m.s[k] = nil end
  s.fx, s.fy = fx, fy
end

-- leaf scrap: flattened onion leaf strap on a shallow diagonal, ragged torn ends
local lm, ln, LT, LS, len = A.blade(7, 53, 30, 52, 57, 40, function(t) return 5.6 + 0.6 * sin(t * 5) end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local a = 0.025 + 0.045 * abs(sin(s * 6.5 + 0.7)) + 0.02 * X.hash(x, y, 3)
  local b = 0.97 - 0.05 * abs(sin(s * 5.3 + 2.1)) - 0.02 * X.hash(x, y, 5)
  if t < a or t > b then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end

-- sprout parts (masks first so the leaf gets their shadows)
local stok = { r = { name = "sprout" } }
local s1 = { { 41, 40 }, { 41, 33 }, { 41, 27 }, { 40, 21 } }
local s2 = { { 40, 21 }, { 39, 13 }, { 32, 11 }, { 31, 19 } }
local m1, n1, T1, S1 = A.tube(s1, function(t) return 1.15 end)
local m2, n2, T2, S2 = A.tube(s2, function(t) return 1.15 - 0.35 * t end)
local root = { { 44, 43 }, { 45, 45 }, { 46, 46 }, { 46, 47 }, { 47, 48 }, { 47, 49 } }
local rm = HP.mask() for _, p in ipairs(root) do rm:set(p[1], p[2]) end
A.cast(bias, lm, m1, 1, 1, -1)
A.cast(bias, lm, rm, 1, 0, -1)

local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, OL, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  -- parallel veins
  for _, v in ipairs{ -0.62, -0.3, 0.3, 0.62 } do
    if abs(s - v) < 0.09 then A.step(c, lidx, OL, x, y, v < 0 and 1 or -1, ltok) end
  end
  -- waxy bloom along the fold
  if s > -0.2 and s < -0.06 and t > 0.12 and t < 0.88 and (x + y) % 5 ~= 0 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.72 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- sprout: blanched foot to green crook
local function tone(m, n, T, foot)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local i = 1 for j, t in ipairs{ 0.25, 0.48, 0.7, 0.88 } do if v[k] >= t then i = j + 1 end end
    if foot and T[k] < 0.4 then i = min(5, i + 2) end
    c:put(x, y, STEM[i], stok)
  end)
end
m2:cut(m1)
tone(m1, n1, T1, true)
tone(m2, n2, T2, false)
-- white root wisp over the leaf
for i, p in ipairs(root) do c:put(p[1], p[2], i < 4 and "#f2ecd6" or "#d8ccae", { r = { name = "root" } }) end

-- seeds: wrinkled black, a flat facet, glossy glint
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sidx = A.shade(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.08, wrap = 0.25 })
  s.m:each(function(x, y) local d = (x - s[1]) * s.fx + (y - s[2]) * s.fy
    if d > 0.7 then A.step(c, sidx, SEED, x, y, (s.fx + s.fy < 0) and 1 or -1, tok) end    -- facet plane
    if d > 0.7 and d <= 1.6 and (x + y) % 2 == 0 then A.step(c, sidx, SEED, x, y, -1, tok) end
    -- wrinkles
    local w = (x - s[1]) * cos(s[5] + 1.3) + (y - s[2]) * sin(s[5] + 1.3)
    if abs(w % 2.3 - 1.1) < 0.35 and d < 0.7 and X.hash(x, y, i) > 0.35 then A.step(c, sidx, SEED, x, y, -1, tok) end
  end)
  local gx, gy = A.specAt(s.m, s.n, 30)
  c:put(gx, gy, GLINT, tok) c:put(gx + 1, gy, SEED[5], tok)
end

-- quirk: empty seed coat hat on the crook tip
local hx, hy = 31, 19
A.map(c, {
  ".ab.",
  "abcc",
  "bccd",
  ".dd.",
}, hx - 2, hy - 1, { a = SEED[5], b = SEED[4], c = SEED[2], d = SEED[1] }, { r = { name = "coat" } })
c:put(hx - 1, hy - 1, GLINT, { r = { name = "coat" } })

A.save(c, NAME)
