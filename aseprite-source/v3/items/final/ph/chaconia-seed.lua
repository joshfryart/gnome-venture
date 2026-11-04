-- chaconia-seed (final, Opus single pass). Three small angular chaconia seeds (russet-brown, a pale hilum scar and a
-- fine ridge) on a torn scrap of chaconia leaf (smooth elliptic blade, sunken midrib, arched pinnate veins, a ragged
-- torn end, cool reflected edge, AO and contact shadow under each seed). The right seed has sprouted: a russet-red
-- stem with two opposite elliptic leaves (chaconia's pinnate veins, pointed tips) and a smaller pair above.
-- quirk: a single scarlet bract (the chaconia's "wild poinsettia" flag) is already unfurling at the sprout's tip.
local NAME = "chaconia-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#163a33", "#1f553d", "#2b7344", "#43924a", "#6db456", "#a4d572" }
local VEIN, COOL = "#c6e690", "#3b6d78"
local SEED = { "#3a1c1e", "#5c2a24", "#83402c", "#a85e38", "#cd8752", "#efbd84" }
local STEM = { "#5a2430", "#8e3a34", "#bf5a40", "#e48c5c" }
local RED = { "#6e1a32", "#a8223a", "#dc3640", "#f56a4a", "#ffa47a", "#ffd9b0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 16, 48, 3.6, 2.4, 0.3 }, { 25, 50, 3.4, 2.3, -0.2 }, { 38, 46, 3.6, 2.5, -0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: elliptic chaconia blade on a shallow diagonal, ragged torn far end
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 57, 57, 43, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.6 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.75)
end, { fold = 0.32 })
-- torn edge: remove everything past a jagged line across the blade near t=0.8
local tear = {}
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local j = 0.79 + 0.035 * sin(s * 9.5) + 0.03 * (X.hash(floor(s * 6), 3, 7) - 0.5)
  if LT[k] > j then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end
local tornEdge = HP.mask()
lm:edge():each(function(x, y) if LT[K(x, y)] > 0.7 then tornEdge:set(x, y) end end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = A.tok("leaf")
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- arched pinnate veins: curve forward toward the tip as they approach the margin
  local ph = (t * len - abs(s) * 5.5 + abs(s) ^ 2 * 2.5) / 6.2
  local f = ph - floor(ph)
  if f < 0.13 and abs(s) > 0.18 and abs(s) < 0.82 and t > 0.06 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.1 and LT[k] < 0.7 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibrous rim
tornEdge:each(function(x, y) if X.hash(x, y, 5) > 0.35 then c:put(x, y, LEAF[6], ltok) end end)
-- petiole stub
for _, q in ipairs{ { 6, 52, 3 }, { 5, 53, 2 }, { 4, 53, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout stem (russet, like the plant's young shoots)
local stok = A.tok("stem")
local sp = { { 38, 45 }, { 37, 38 }, { 38, 30 }, { 38, 20 } }
local sm, sn = A.tube(sp, function(t) return 1.05 - 0.25 * t end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- leaves: elliptic, pointed, opposite pairs with pinnate veins
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, w * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.8)
  end, { fold = 0.35 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.15 and t > 0.08 and t < 0.88 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
    local ph = (t * L - abs(s) * 2.6) / 3.4
    if ph - floor(ph) < 0.22 and abs(s) > 0.25 and abs(s) < 0.8 and t > 0.15 and t < 0.85 then
      c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end)
  return m
end
local L1 = leaf(37, 31, 28, 30, 19, 23, 3.4)
local L2 = leaf(39, 31, 48, 30, 56, 23, 3.4)
local L3 = leaf(37, 22, 32, 20, 28, 15, 2.2)
local L4 = leaf(39, 22, 44, 20, 48, 15, 2.2)
-- AO on the stem where the leaf pairs leave it
for _, y in ipairs{ 31, 32, 22 } do for x = 37, 39 do if sm:has(x, y) then c:put(x, y, STEM[1], stok) end end end

-- quirk: scarlet bract unfurling at the tip (one big sepal-flag, veined)
local bm, bn, BT, BS, BL = A.blade(38, 20, 37, 15, 41, 9, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 2.8 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7)
end, { fold = 0.25 })
bm:cut(L3):cut(L4)
local rtok = A.tok("bract")
A.toneN(c, bm, bn, RED, { tok = rtok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y)
  if abs(BS[k]) < 0.15 and BT[k] > 0.1 and BT[k] < 0.85 then c:put(x, y, BS[k] <= 0 and RED[5] or RED[2], rtok) end end)
-- tiny bud tucked under the bract
local bud = c:ellipse(36, 18, 1, 1)
bud:cut(bm)
bud:each(function(x, y) c:put(x, y, (x + y < 54) and RED[4] or RED[2], rtok) end)

-- seeds last: angular, ridged, a pale hilum scar
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = A.tok("seed" .. i)
  local v = X.light(s.n, { amb = 0.08, wrap = 0.2 })
  local idx = X.tone(c, vis, v, SEED, { cuts = CUTS, bias = sb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    -- faceted ridge along the seed: one row darker just below the crest
    if w > 0.05 and w < 0.4 and abs(u) < 0.7 then A.step(c, idx, SEED, x, y, -1, tok) end
  end)
  -- hilum: pale 1 px scar at one end, plus a 2x1 specular on the crest
  local hx = floor(s[1] + (s[3] - 0.6) * ca + 0.5)
  local hy = floor(s[2] + (s[3] - 0.6) * sa + 0.5)
  if vis:has(hx, hy) then c:put(hx, hy, SEED[6], tok) end
end
c:px(14, 46, A.CREAM) c:px(15, 46, SEED[6])
c:px(36, 44, SEED[6])

A.save(c, NAME)
