-- fennel-seed (B31, Opus single pass). Three long khaki-green fennel seeds (ridged: five pale ribs with dark grooves
-- between, pointed ends) on a blue-green leaf scrap torn off ragged at its right end (midrib, swept veins, V-fold,
-- cool reflected edge, AO + contact shadow under each seed). The top seed has sprouted: a pale stem, two long
-- strap cotyledons and a first true leaf of forked hair-fine threads, the fennel frond in miniature.
-- quirk: the lower seed still wears its tiny curled umbel stalk.
local NAME = "fennel-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new(NAME)

local LEAF = { "#163c38", "#205844", "#2d744e", "#479456", "#71b664", "#a6d886" }
local VEIN, COOL = "#c0e49a", "#3c6e78"
local SEED = { "#35341f", "#5a582f", "#807b40", "#a69f54", "#c9c378", "#eae6a6" }
local STEM = { "#4c8656", "#84b86e", "#b6da96", "#e2f2c2" }
local TAN = { "#6a5030", "#a08050" }

-- leaf scrap on a shallow diagonal, right end torn ragged
local lm, ln, LT, LS, len = G.blade(7, 50, 30, 55, 55, 41, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.82 + 0.06)) ^ 0.65)
end, { fold = 0.4 })
local tear = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.07 * sin(LS[k] * 9.0) + 0.05 * (X.hash(x, y, 3) - 0.5)
  if LT[k] > lim then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end

local seeds = { { 18, 47, 4.6, 1.7, -0.08 }, { 30, 47, 4.6, 1.7, 0.42 }, { 37, 40, 4.4, 1.7, -0.62 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -2) G.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = G.shade(c, lm, ln, LEAF, { bias = bias, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3]) return end
  local ph = (t * len - abs(s) * 5.0) / 6.5
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.75 and t > 0.06 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2]) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.74 then c:put(x, y, COOL, nil) end end)
-- torn end: pale fibrous edge
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] > 0.7 and not bias[k] and abs(LS[k]) < 0.85 then c:put(x, y, LEAF[5]) end end)
-- petiole stub
for _, q in ipairs{ { 6, 51, 4 }, { 5, 52, 3 }, { 4, 53, 3 } } do c:put(q[1], q[2], LEAF[q[3]]) end

-- sprout from the top seed
local sp = { { 38, 38 }, { 37, 32 }, { 39, 27 }, { 38, 21 } }
local sm, sn = G.tube(sp, function() return 1.0 end)
sm:cut(seeds[3].m)
G.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local function coty(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 1.35 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.45)
  end, { fold = 0.3 })
  m:cut(sm)
  G.shade(c, m, n, LEAF, { amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end end)
  return m
end
coty(37, 22, 30, 21, 24, 15)
coty(39, 22, 46, 22, 52, 17)
-- true leaf: thread frond on a short petiole
G.pline(c, { { 38, 21 }, { 38, 15 } }, STEM[2])
local function thr(x, y, a, L, d)
  local dx, dy = sin(a), -cos(a)
  for s = 1, L do
    local xi, yi = floor(x + dx * s + .5), floor(y + dy * s + .5)
    c:put(xi, yi, (a < 0.1) and LEAF[5] or LEAF[4])
    if d > 0 and s == L - 1 then thr(x + dx * s, y + dy * s, a + 0.7, 2, d - 1) thr(x + dx * s, y + dy * s, a - 0.7, 2, d - 1) end
  end
end
thr(38, 15, -0.9, 4, 1) thr(38, 15, 0.0, 4, 1) thr(38, 15, 0.9, 4, 1)
c:put(38, 15, STEM[3])

-- seeds: ridged backs (ribs and grooves along the length), pointed tips, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local ca, sa = cos(s[5]), sin(s[5])
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local w = (-dx * sa + dy * ca) / (s[4] + .45)
    local idx = 1
    for jj, t in ipairs{ 0.18, 0.34, 0.5, 0.66, 0.84 } do if v[k] >= t then idx = jj + 1 end end
    -- rib / groove alternation across the seed
    local band = floor((w + 1) * 2.0 + 0.5)
    if band % 2 == 0 then idx = idx + 1 else idx = idx - 1 end
    if abs(u) > 0.8 then idx = idx - 1 end
    if sb[k] then idx = idx - 1 end
    if w > 0.62 then idx = idx - 1 end
    c:put(x, y, SEED[max(1, min(6, idx))])
  end)
end
-- one glint on the front seed
c:put(15, 46, "#fff4d6") c:put(16, 46, "#fff4d6")

-- quirk: curled umbel stalk on the lower-left seed's tip
G.pline(c, { { 13, 48 }, { 11, 48 }, { 10, 47 } }, TAN[2])
c:put(10, 46, TAN[2]) c:put(11, 45, TAN[1])

G.save(c, NAME)
