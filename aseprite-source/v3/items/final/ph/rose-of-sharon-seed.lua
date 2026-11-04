-- rose-of-sharon-seed (final pass, Sonnet). Four flat kidney seeds (grey-brown, speckled, dark hilum notch, fringed
-- with pale hairs) on a torn hibiscus-syriacus leaf scrap (toothed margin, three main veins fanning from the base,
-- V-fold light, cool reflected edge, AO + contact shadow under every seed). The right seed has split: pale kernel
-- showing, a pale radicle, a stem with two heart-shaped mallow cotyledons and a tiny three-lobed first true leaf.
-- quirk: a crumpled magenta petal with a crimson throat is lying under the torn tip of the leaf.
local NAME = "rose-of-sharon-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#1b3f33", "#28593a", "#3b7a3e", "#58a044", "#84c258", "#b9df7e" }
local VEIN, COOL = "#cfe99a", "#3c6e70"
local SEED = { "#2c211f", "#46362f", "#6a5645", "#8f7961", "#b39c7c", "#d9c8a2" }
local HAIR_HI, HAIR_LO = "#f3ead0", "#b19a74"
local STEM = { "#4d8a52", "#86b86a", "#b8dc90", "#e4f4be" }
local PET = { "#4e1442", "#7d1f64", "#b0368a", "#d85aa4", "#f088c2", "#ffc4e2" }
local CUTS = A.CUTS
local ltok = { r = { name = "leaf" } }

local seeds = { { 16, 53, 4.4, 2.8, 0.3 }, { 26, 56, 4.3, 2.7, -0.22 }, { 33, 49, 4.3, 2.7, 0.55 }, { 43, 46, 4.5, 2.9, -1.2 } }
for _, s in ipairs(seeds) do
  s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8)
  -- kidney notch on the concave side
  local nx, ny = -sin(s[5]), cos(s[5])
  s.hx, s.hy = floor(s[1] + nx * (s[4] + 0.2) + 0.5), floor(s[2] + ny * (s[4] + 0.2) + 0.5)
  local nm = HP.mask() nm:set(s.hx, s.hy) s.m:cut(nm)
end

-- quirk: magenta petal under the torn tip
local pm, pn = G.oval(49, 55, 5.4, 3.3, -0.45, 0.6)
local ptok = { r = { name = "petal" } }
G.toneN(c, pm, pn, PET, { tok = ptok, cuts = CUTS, amb = 0.1, wrap = 0.3 })
pm:each(function(x, y)
  if (x - 45) ^ 2 + (y - 57) ^ 2 < 5.5 then c:put(x, y, (x + y) % 2 == 0 and "#6a1450" or "#8c1e5a", ptok) end
end)
A.line(c, 47, 55, 53, 52, PET[2], ptok) A.line(c, 48, 54, 52, 51, PET[6], ptok)

-- leaf scrap: ovate, toothed, torn at the tip
local PER = 5.6
local lm, ln, LT, LS, len = G.blade(6, 52, 24, 55, 52, 44, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, t * 0.96 + 0.04)
  return max(0.5, 9.2 * sin(pi * u ^ 0.9) ^ 0.7)
end, { fold = 0.4 })
local cutm = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  local lim = 1.0 - 0.32 * f
  if t > 0.1 and abs(s) > lim then cutm:set(x, y) end
  if t > 0.86 + 0.07 * (X.hash(x, y, 3) - 0.5) * 2 then cutm:set(x, y) end
end)
lm:cut(cutm)
-- a bite out of the lower margin
lm:cut(c:ellipse(22, 61, 3, 2))
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- two main laterals fanning out from the base
  if t < 0.66 and abs(abs(s) - (0.12 + 0.95 * t ^ 0.8)) < 0.075 and abs(s) > 0.2 then
    c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  local ph = (t * len - abs(s) * 3.2) / 4.6
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.3 and abs(s) < 0.78 and t > 0.3 and t < 0.84 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.1 and LT[k] < 0.8 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: pale fringe just inside the tear
lm:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.74 and not lm:has(x + 1, y + 1) and X.hash(x, y, 9) > 0.45 and not bias[k] then c:put(x, y, LEAF[6], ltok) end end)

-- sprout from the split seed D: stem, cotyledons, first true leaf
local D = seeds[4]
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 42, 44 }, { 41, 38 }, { 41, 32 }, { 41, 27 } }, function() return 1.1 end)
sm:cut(D.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function cotyledon(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, 3.7 * sin(pi * min(1, t * 0.82 + 0.12)) ^ 0.55)
  end, { fold = 0.3 })
  local cleft = HP.mask()
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.88 and abs(S[k]) < 0.22 then cleft:set(x, y) end end)
  m:cut(cleft):cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], ltok) end end)
  return m
end
local cl = cotyledon(41, 29, 34, 29, 27, 23)
local cr = cotyledon(41, 29, 48, 29, 55, 23)
local ptl = G.tube({ { 41, 28 }, { 41, 25 }, { 41, 23 }, { 41, 21 } }, function() return 0.9 end)
local tl = HP.mask()
tl:add(G.rell(41, 16.5, 0, -1, 4.4, 2.2))
tl:add(G.rell(37.4, 19.6, -0.75, -0.66, 3.6, 1.8))
tl:add(G.rell(44.6, 19.6, 0.75, -0.66, 3.6, 1.8))
tl:cut(cl):cut(cr)
G.toneN(c, tl, X.pillow(tl, 1.8), LEAF, { tok = ltok, cuts = CUTS, amb = 0.12, wrap = 0.25 })
A.line(c, 41, 21, 41, 13, VEIN, ltok) A.line(c, 41, 21, 36, 18, VEIN, ltok) A.line(c, 41, 21, 46, 18, LEAF[3], ltok)
for _, q in ipairs{ { 41, 22, 2 }, { 41, 23, 3 }, { 41, 24, 3 }, { 41, 25, 2 }, { 41, 26, 3 } } do c:put(q[1], q[2], STEM[q[3]], stok) end
-- radicle poking out of the seed's lower end into the leaf
local rm, rn = G.tube({ { 40, 48 }, { 39, 51 }, { 37, 53 }, { 35, 54 } }, function(t) return 1.1 * (1 - t) + 0.3 end)
rm:cut(D.m)
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
c:put(34, 55, STEM[2], stok) c:put(33, 55, STEM[1], stok)

-- seeds last: speckled grey-brown flat kidneys, hairy fringe
for i, s in ipairs(seeds) do
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  s.m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 21 + i)
    sb[k] = (sb[k] or 0) + (h < 0.16 and -1 or (h > 0.88 and 1 or 0)) end)
  local tok = { r = { name = "seed" .. i } }
  G.toneN(c, s.m, s.n, SEED, { bias = sb, tok = tok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
  -- hilum notch: dark pixel just inside, pale scar beside it
  local ix, iy = floor(s[1] + (s.hx - s[1]) * 0.55 + 0.5), floor(s[2] + (s.hy - s[2]) * 0.55 + 0.5)
  if s.m:has(ix, iy) then c:put(ix, iy, SEED[1], tok) end
  c:put(s.hx, s.hy, SEED[1], tok)
  -- fringe of fine hairs
  local ring = s.m:grow(1):cut(s.m)
  ring:each(function(x, y)
    local over = false
    for j = i + 1, #seeds do if seeds[j].m:has(x, y) then over = true end end
    if not over and X.hash(x, y, 40 + i) > 0.6 and not (x == s.hx and y == s.hy) then
      c:put(x, y, (x + y < s[1] + s[2]) and HAIR_HI or HAIR_LO, tok) end
  end)
  local sx, sy = G.specAt(s.m, s.n, 30)
  if sx then c:put(sx, sy, SEED[6], tok) end
end
-- split seed: pale kernel showing at the stem end, dark crack
c:put(43, 43, "#f1e4b0", { r = { name = "kernel" } }) c:put(42, 43, "#d8c58a", { r = { name = "kernel" } })
c:put(43, 44, "#c9b078", { r = { name = "kernel" } })
G.save2(c, NAME)
