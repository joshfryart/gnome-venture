-- coneflower-seed (final, Opus single pass). Three coneflower achenes (slim four-angled wedges, ash-tan with a lit facet,
-- a pale ridge and a toothed crown at the wide end) on a torn scrap of rough lance-shaped coneflower leaf (three
-- arching parallel veins, tiny bristles, V-fold light, cool reflected edge, AO + contact shadow under each seed).
-- The right seed has germinated: green stem, two oval cotyledons, and a first true leaf, lance-shaped and toothed.
-- quirk: one fallen rose-pink ray petal with a notched tip lies across the leaf.
local NAME = "coneflower-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1e3d2e", "#2a5636", "#3d7040", "#568c48", "#78a852", "#a6c870" }
local VEIN, COOL, HAIR = "#c4dc8a", "#3a6670", "#d8e8a8"
local SEED = { "#3a2a26", "#5c4334", "#806046", "#a28462", "#c6aa84", "#e6d2ae" }
local SPR = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92" }
local PET = { "#7d2c5e", "#b04880", "#de6c9e", "#f598bc", "#ffc8dc" }

-- leaf scrap: lance-shaped, lying across, torn at the left end
local lm, ln, LT, LS, len = A.blade(6, 50, 30, 41, 58, 45, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.6 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.75)
end, { fold = 0.42 })
A.tear(lm, 13, 40, 9, 58, -1, 4)

-- seeds
local seeds = { { 18, 47, -0.25 }, { 29, 49, 0.1 }, { 37, 44, -1.3 } }
local function seedMask(s)
  local m, U, V = HP.mask(), {}, {}
  local ca, sa = cos(s[3]), sin(s[3])
  local px, py = -sa, ca
  local flip = (px + py) > 0 and 1 or -1
  for y = s[2] - 6, s[2] + 6 do for x = s[1] - 6, s[1] + 6 do
    local dx, dy = x - s[1], y - s[2]
    local u = dx * ca + dy * sa
    local v = flip * (dx * px + dy * py)
    local hw = 0.8 + (u + 4.6) / 9.2 * 2.2
    if u >= -4.6 and u <= 4.4 and abs(v) <= hw then m:set(x, y) local k = K(x, y) U[k], V[k] = u, v / hw end
  end end
  return m, U, V
end
for _, s in ipairs(seeds) do s.m, s.U, s.V = seedMask(s) end

-- petal (quirk) mask
local pm, pn, PT, PS = A.blade(44, 47, 49, 49, 55, 45, function(t)
  if t > 0.97 then return -1 end
  return max(0.6, 1.9 * sin(pi * min(1, t * 0.7 + 0.25)) ^ 0.6)
end, { fold = 0.2 })
-- notch at the tip
pm:each(function(x, y) local k = K(x, y) if PT[k] > 0.86 and abs(PS[k]) < 0.25 then pm.s[k] = nil end end)

-- tone the leaf with AO + cast shadow from seeds and petal
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, pm, 1, -1) A.cast(bias, lm, pm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 }, amb = 0.12, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.12 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- two arching side veins each side, running parallel to the margin
  for _, vs in ipairs{ 0.5 } do
    local target = vs * (1 - (t - 0.5) ^ 2 * 1.2)
    if abs(abs(s) - target) < 0.09 and t > 0.15 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  end
  -- bristles: sparse pale specks on the lit half
  if s < -0.2 and X.hash(x, y, 77) > 0.93 then c:put(x, y, HAIR, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- tiny marginal hairs outside the lit edge
for _, h in ipairs{ {22, 37}, {31, 36}, {41, 37}, {50, 40} } do if not lm:has(h[1], h[2]) and lm:has(h[1], h[2] + 1) then c:put(h[1], h[2], LEAF[5], ltok) end end

-- sprout (behind the third seed)
local stok = { r = { name = "stem" } }
local sp = { { 37, 43 }, { 36, 35 }, { 38, 26 }, { 37, 18 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.35, 0.7 }, tok = stok })
local function blade2(ax, ay, cx, cy, bx, by, w, teeth)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  if teeth then
    local cut = {}
    m:each(function(x, y) local k = K(x, y)
      local ph = (T[k] * L / 2.2) % 1
      if abs(S[k]) > 0.72 and ph < 0.45 and T[k] > 0.2 and T[k] < 0.9 then cut[#cut + 1] = k end end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  A.toneN(c, m, n, SPR, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and SPR[6] or SPR[3], ltok) end end)
  return m
end
blade2(36, 24, 31, 22, 26, 25, 2.2)     -- left cotyledon (oval)
blade2(38, 24, 43, 21, 48, 23, 2.2)     -- right cotyledon
blade2(37, 19, 35, 12, 39, 5, 3.0, true) -- first true leaf, lance and toothed

-- petal
local ptok = { r = { name = "petal" } }
A.toneN(c, pm, pn, PET, { tok = ptok, cuts = { 0.2, 0.4, 0.62, 0.84 }, amb = 0.15, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  if abs(PS[k] - 0.35) < 0.12 and PT[k] > 0.15 and PT[k] < 0.8 then c:put(x, y, PET[3], ptok) end end)

-- seeds last: lit facet, ridge, shade facet, toothed crown at the wide end
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  s.m:each(function(x, y) local k = K(x, y)
    local u, v = s.U[k], s.V[k]
    local idx
    if v < -0.55 then idx = 4 elseif v < -0.1 then idx = 5 elseif v < 0.2 then idx = 6 elseif v < 0.6 then idx = 3 else idx = 2 end
    if u < -3.2 then idx = idx - 1 end
    if u > 3.5 then idx = idx - 1 end
    if sb[k] then idx = idx - 1 end
    c:put(x, y, SEED[max(1, min(6, idx))], tok)
  end)
  -- crown teeth
  local ca, sa = cos(s[3]), sin(s[3])
  local px, py = -sa, ca
  for _, v in ipairs{ -2.2, 0, 2.2 } do
    local x = floor(s[1] + 5.4 * ca + v * px + .5)
    local y = floor(s[2] + 4.6 * sa + v * py + .5)
    if not s.m:has(x, y) then c:put(x, y, v < 0.5 and SEED[6] or SEED[4], tok) end
  end
end
-- glint on the front seed
c:put(28, 48, "#fff4d6")

A.save(c, NAME)
