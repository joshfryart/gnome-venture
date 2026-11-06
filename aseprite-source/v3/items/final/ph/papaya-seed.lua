-- papaya-seed (final, Opus). Four papaya seeds on a torn papaya-leaf scrap. Each seed is a round, wrinkled black-brown
-- peppercorn (6-tone, bumpy per-pixel bias) still wrapped in its glossy amber gel sac (pale rim, one bright glint),
-- with AO + contact shadow on the leaf. The scrap is a palmate lobe torn across (ragged edge with a pale torn fibre
-- line), midrib + veins, V-fold light, cool reflected edge. The front-right seed has germinated: a pale stem, two oval
-- cotyledons and a first true leaf that is already deeply palmate with jagged lobes, showing the papaya leaf.
-- quirk: the left cotyledon still wears the seed's wrinkled black coat like a little hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local NAME = "papaya-seed"
local c = A.new(NAME)

local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL, TORN = "#c8e692", "#3a6c72", "#d8eaa6"
local SEED = { "#211620", "#33212b", "#47303a", "#5e4550", "#7e6670", "#a6929a" }
local GEL  = { "#b8662e", "#e08c3c", "#f8b862", "#ffe0a0" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }

-- leaf scrap: broad lobe lying across the bottom, tip to the right, torn across on the left
local lm, ln, LT, LS, len = A.blade(9, 50, 30, 41, 56, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 7.6 * sin(pi * min(1, t * 0.55 + 0.45)) ^ 0.6)
end, { fold = 0.36 })
-- torn left end: ragged column cut; jagged teeth along the right lobe margin
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local tear = 11 + floor(X.hash(0, y, 9) * 3) + ((y % 3 == 0) and 1 or 0)
  if x < tear then cut[#cut + 1] = k end
  if LT[k] > 0.55 and abs(LS[k]) > 0.82 and floor(LT[k] * len) % 3 == 0 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil ln[k] = nil end

-- seeds: x, y, r
local seeds = { { 21, 45, 3.1 }, { 29, 49, 3.0 }, { 36, 44, 3.1 }, { 44, 48, 3.0 } }
for _, s in ipairs(seeds) do
  s.m = c:ellipse(s[1], s[2], s[3], s[3] - 0.3)
  s.core = c:ellipse(s[1], s[2], s[3] - 1, s[3] - 1.3)
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.06 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 6) % 6
  if d < 0.9 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.1 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if x <= 14 then c:put(x, y, TORN, ltok)                                          -- pale torn fibres
  elseif LS[k] > 0.66 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- sprout from the front-right seed (behind the seeds)
local stem = { { 44, 46 }, { 45, 38 }, { 42, 32 }, { 43, 25 } }
local sm, sn = A.tube(stem, function(t) return 1.1 - 0.15 * t end)
for _, s in ipairs(seeds) do sm:cut(s.m) end
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function cotyledon(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 2.1 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.6)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = cotyledon(42, 32, 37, 31, 32, 28)
local cr = cotyledon(44, 32, 49, 32, 54, 29)
-- quirk: seed coat hat on the left cotyledon tip
for _, q in ipairs{ { 31, 27, 3 }, { 32, 27, 4 }, { 30, 28, 2 }, { 31, 28, 3 }, { 32, 28, 2 }, { 30, 29, 1 }, { 31, 29, 2 }, { 33, 27, 3 }, { 32, 26, 5 } } do
  c:put(q[1], q[2], SEED[q[3]], ltok) end
c:put(31, 27, SEED[6], ltok)

-- first true leaf: deeply palmate, 5 jagged lobes radiating from the petiole top
local PCX, PCY = 43, 18
local tl = HP.mask()
local lobes = { { -150, 7.5 }, { -118, 9.5 }, { -90, 10.5 }, { -62, 9.5 }, { -30, 7.5 } }
local lobeData = {}
for _, q in ipairs(lobes) do
  local a = q[1] * pi / 180
  local ux, uy = cos(a), sin(a)
  local L = q[2]
  local m, n, T, S, ll = A.blade(PCX, PCY, PCX + ux * L * 0.5, PCY + uy * L * 0.5, PCX + ux * L, PCY + uy * L, function(t)
    if t > 0.98 then return -1 end
    local w = 2.3 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7
    -- jagged side lobes
    if t > 0.35 and t < 0.85 and (floor(t * L * 0.55) % 2 == 0) then w = w + 0.9 end
    return max(0.4, w)
  end, { fold = 0.4 })
  lobeData[#lobeData + 1] = { m = m, n = n, T = T, S = S }
  tl:add(m)
end
for i, d in ipairs(lobeData) do
  local b = {}
  if i ~= 3 then X.ao(b, d.m, lobeData[3].m, 1, -1) d.m:cut(lobeData[3].m) end
  A.toneN(c, d.m, d.n, LEAF, { tok = ltok, bias = b, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.28 })
  d.m:each(function(x, y) local k = K(x, y) if abs(d.S[k]) < 0.16 and d.T[k] > 0.08 and d.T[k] < 0.86 then c:put(x, y, d.S[k] <= 0 and LEAF[6] or LEAF[2], ltok) end end)
end
c:put(PCX, PCY, LEAF[1], ltok) c:put(PCX, PCY + 1, STEM[1], stok)
-- petiole from stem top to the leaf
for y = PCY + 1, 25 do c:put(43, y, STEM[3], stok) c:put(44, y, STEM[1], stok) end

-- seeds last: gel sac rim + wrinkled peppercorn core
for i, s in ipairs(seeds) do
  local tk = { r = { name = "seed" .. i } }
  local sn = X.sphere(s[1], s[2], s[3], s.m)
  local gv = X.light(sn, { amb = 0.15, wrap = 0.3 })
  X.tone(c, s.m, gv, GEL, { cuts = { 0.3, 0.55, 0.8 }, tok = tk })
  local sb = {}
  s.core:each(function(x, y) local h = X.hash(x, y, i * 7) if h > 0.72 then sb[K(x, y)] = 1 elseif h < 0.22 then sb[K(x, y)] = -1 end end)
  local cv = X.light(X.sphere(s[1], s[2], s[3] - 1, s.core), { amb = 0.05, wrap = 0.2 })
  X.tone(c, s.core, cv, SEED, { cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, bias = sb, tok = tk })
  -- gel glint upper-left
  c:put(floor(s[1] - s[3] + 1.5), floor(s[2] - s[3] + 1.6), GEL[4], tk)
end
-- one bright specular on the front seed's gel
c:put(35, 42, "#fff4d6", { r = { name = "seed3" } })

A.save(c, NAME)
