-- fig-seed (Opus single pass, aB31_3). Tiny golden fig seeds (rounded, 6-tone, lit cap + dark keel) on a torn scrap
-- of fig leaf: three palmate lobes from one base, each with its own V-fold light, pale palmate midribs and side veins,
-- a ragged torn edge in pale torn-tissue tones, cool reflected light on the lower rims, AO + contact shadow under seeds.
-- One seed has sprouted: pale stem, two round cotyledons and a first true leaf that is already a three-lobed fig leaf.
-- quirk: two seeds are still stuck in a smear of pink fig pulp.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new("fig-seed")
local LEAF = { "#163832", "#1f523e", "#2c6c46", "#43894c", "#66a956", "#97c86c" }
local VEIN, COOL, TORN = "#bfe08a", "#3a6a74", "#d8e8a0"
local SEED = { "#4a2c1c", "#74482a", "#a06c34", "#c8944a", "#e8bc6a", "#fbe2a0" }
local PULP = { "#6a1e3a", "#9a2d4a", "#c84a5e", "#e8707a", "#f8a0a0", "#ffd0c8" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local LCUTS = { 0.18, 0.33, 0.5, 0.66, 0.82 }

-- leaf scrap: three lobes from a common base (lower left), the long middle lobe torn off at the right
local BX, BY = 12, 53
local lobes = {
  { BX, BY, 27, 47, 50, 44, 6.4 },   -- middle
  { BX, BY, 17, 41, 27, 32, 4.4 },   -- upper
  { BX, BY, 22, 58, 35, 59, 4.0 },   -- lower
}
local leaf = HP.mask()
local LN, LT, LS, LI = {}, {}, {}, {}
for i, L in ipairs(lobes) do
  local m, n, T, S = A.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.985 then return -1 end
    return max(0.6, L[7] * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.75)
  end, { fold = 0.4 })
  m:each(function(x, y) local k = K(x, y)
    if not LI[k] or abs(S[k]) < abs(LS[k]) then LN[k], LT[k], LS[k], LI[k] = n[k], T[k], S[k], i end end)
  leaf:add(m)
end
-- torn edge: jagged cut across the middle lobe
local torn = {}
local jag = { 0, 2, 1, 3, 1, 2, 0, 2 }
leaf:each(function(x, y) local lim = 44 + jag[(y % #jag) + 1] - (y - 44) * 0.3
  if LI[K(x, y)] == 1 and x > lim then leaf.s[K(x, y)] = nil end end)
leaf:each(function(x, y) if LI[K(x, y)] == 1 and not leaf:has(x + 1, y) and x > 40 then torn[K(x, y)] = true end end)

-- seeds: {cx, cy, r}
local seeds = { { 20, 47, 1.7 }, { 31, 51, 1.6 }, { 27, 46, 1.5 }, { 40, 49, 1.8 } }
local pulp = HP.ellipse(23, 53, 4.2, 2.2)
local pseeds = { { 21, 53, 1.3 }, { 25, 52, 1.3 } }
for _, s in ipairs(seeds) do s.m = HP.ellipse(s[1], s[2], s[3], s[3] * 0.85) end
for _, s in ipairs(pseeds) do s.m = HP.ellipse(s[1], s[2], s[3], s[3] * 0.85) end

-- sprout from seed 4
local sp = { { 40, 47 }, { 41, 40 }, { 37, 32 }, { 38, 25 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, leaf, s.m, 1, -1) A.cast(bias, leaf, s.m, 1, 1, -1) end
X.ao(bias, leaf, pulp, 1, -1) A.cast(bias, leaf, pulp, 1, 1, -1)
A.cast(bias, leaf, sm, 1, 1, -1)
local ltok = A.tok("leaf")
local v = X.light(LN, { amb = 0.1, wrap = 0.28 })
X.tone(c, leaf, v, LEAF, { bias = bias, tok = ltok, cuts = LCUTS })
-- palmate veins: midrib of each lobe (lit half pale) + side veins swept toward the tip
leaf:each(function(x, y) local k = K(x, y) local s, t, i = LS[k], LT[k], LI[k]
  if bias[k] or torn[k] then return end
  if abs(s) < 0.13 and t > 0.02 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * 34 - abs(s) * 4.5) / 5.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.18 and abs(s) < 0.75 and t > 0.12 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- cool reflected light on lower rims, pale torn tissue on the ripped edge
leaf:edge():each(function(x, y) local k = K(x, y)
  if torn[k] then c:put(x, y, TORN, ltok)
  elseif not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
for k in pairs(torn) do local x, y = k % 1024 - 256, k // 1024 - 256 if leaf:has(x - 1, y) and not bias[K(x - 1, y)] then c:put(x - 1, y, LEAF[5], ltok) end end
-- petiole stub
for _, q in ipairs{ { 11, 54, 3 }, { 10, 55, 2 }, { 9, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout: stem, cotyledons, three-lobed true leaf
local stok = A.tok("stem")
local sv = sm:copy():cut(seeds[4].m)
A.tone(c, sv, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
local function cot(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.5)
  end, { fold = 0.3 })
  m:cut(sm)
  A.tone(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = cot(37, 28, 34, 27, 30, 29, 1.7)
local cr = cot(39, 28, 42, 26, 46, 27, 1.7)
-- true leaf: petiole + three rounded lobes (fig leaf in miniature), palmate veins
local tl = HP.mask()
tl:add(A.rell(38, 15, 0.05, -1, 4.8, 2.4))         -- middle lobe
tl:add(A.rell(33.5, 18.5, -0.85, -0.5, 4.3, 1.9))   -- left lobe
tl:add(A.rell(42.5, 18.5, 0.85, -0.5, 4.3, 1.9))    -- right lobe
tl:add(A.rell(38, 20, 1, 0, 2.6, 2.2))             -- heart of the leaf
-- sinuses between lobes
for _, q in ipairs{ { 35, 16 }, { 41, 16 }, { 35, 15 }, { 41, 15 }, { 36, 16 }, { 40, 16 } } do tl.s[K(q[1], q[2])] = nil end
tl:cut(cl):cut(cr)
local tn = X.pillow(tl, 1.8)
local tb = {}
X.ao(tb, tl, sm, 1, -1)
A.tone(c, tl, tn, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.12, wrap = 0.28, bias = tb })
-- palmate midribs from the leaf base
A.curve(c, { { 38, 22 }, { 38, 18 }, { 38, 14 }, { 38, 12 } }, VEIN, ltok, 20)
A.curve(c, { { 38, 21 }, { 36, 20 }, { 33, 18 }, { 31, 17 } }, LEAF[6], ltok, 20)
A.curve(c, { { 38, 21 }, { 40, 20 }, { 43, 18 }, { 45, 17 } }, LEAF[3], ltok, 20)
-- petiole joining the stem
c:put(38, 23, STEM[3], stok) c:put(38, 24, STEM[2], stok)

-- pulp smear (quirk) with two seeds stuck in it
local ptok = A.tok("pulp")
A.tone(c, pulp, X.pillow(pulp, 1.6), PULP, { tok = ptok, amb = 0.15, wrap = 0.3 })
pulp:each(function(x, y) if X.hash(x, y, 5) < 0.12 then c:put(x, y, PULP[2], ptok) end end)
c:put(26, 52, PULP[6], ptok)

-- seeds last: rounded golden nubs, lit cap, dark keel lower right
local function seed(s, tag)
  local tok = A.tok("seed" .. tag)
  local n = X.sphere(s[1], s[2], s[3], s.m)
  A.tone(c, s.m, n, SEED, { tok = tok, amb = 0.06, wrap = 0.2 })
  local x, y = floor(s[1] - 0.5 + .5), floor(s[2] - 0.5 + .5)
  c:put(x, y, SEED[6], tok)
end
for i, s in ipairs(seeds) do seed(s, i) end
for i, s in ipairs(pseeds) do seed(s, "p" .. i) end
-- sprouted seed: split coat showing the pale stem foot
c:put(40, 48, STEM[3], stok) c:put(41, 48, SEED[2])
A.save(c, "fig-seed")
