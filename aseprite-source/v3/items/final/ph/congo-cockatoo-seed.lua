-- congo-cockatoo-seed (final, Opus single pass). Congo cockatoo is a touch-me-not (Impatiens): three glossy round
-- chestnut seeds (sphere light, pale hilum, one glint each) on a torn scrap of its broad oval leaf (fine saw-toothed
-- margin, midrib and curved pinnate veins, glossy hi band, cool edge, AO + contact shadow). The left seed has
-- sprouted on a juicy red stem (typical of the plant) with two round cotyledons and a first toothed oval leaf.
-- quirk: the seed capsule that flung them out lies burst beside them, its valves sprung into a straw-and-red coil.
local NAME = "congo-cockatoo-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#163a2e", "#205238", "#2c6e3e", "#3f8c44", "#5eaa4c", "#93cc68" }
local VEIN, COOL = "#b8de86", "#33627a"
local SEED = { "#2a1618", "#4a2420", "#6e3a26", "#924e2c", "#b46c3a", "#d8955a" }
local RED = { "#5a1630", "#8e2238", "#c43a40", "#ec6a5a" }
local SPR = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local POD = { "#5a3a2a", "#9a7038", "#d0aa58", "#f2dc96" }

-- leaf scrap: broad oval, tip to the left, torn across the base on the right
local lm, ln, LT, LS, len = A.blade(55, 47, 33, 37, 9, 47, function(t)
  if t > 0.985 then return -1 end
  local u = 1 - t
  return max(0.5, 9.4 * sin(pi * min(1, u * 0.85 + 0.12)) ^ 0.8)
end, { fold = 0.35 })
-- saw teeth along the margin
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local ph = (LT[k] * len / 2.6 + (LS[k] > 0 and 0.5 or 0)) % 1
  if abs(LS[k]) > 0.8 and ph < 0.4 and LT[k] > 0.14 and LT[k] < 0.93 then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
A.tear(lm, 50, 34, 54, 58, 1, 6)

-- seeds: round, glossy
local seeds = { { 19, 44, 2.6 }, { 28, 48, 2.6 }, { 35, 43, 2.4 } }
for _, s in ipairs(seeds) do
  s.m = HP.mask()
  for y = s[2] - 4, s[2] + 4 do for x = s[1] - 4, s[1] + 4 do
    if (x - s[1]) ^ 2 + (y - s[2]) ^ 2 <= (s[3] + 0.4) ^ 2 then s.m:set(x, y) end end end
  s.n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3], s.m)
end

-- burst capsule coil (quirk)
local coil, cang = HP.mask(), {}
local CX, CY = 44, 41
local samples = {}
for i = 0, 140 do
  local t = i / 140
  local a = -0.6 + t * 1.45 * 2 * pi
  local r = 1.0 + t * 5.6
  samples[#samples + 1] = { CX + cos(a) * r, CY + sin(a) * r * 0.8, a, t }
end
-- tail: the valve's straight base running off to the right
for i = 0, 20 do local t = i / 20 samples[#samples + 1] = { CX + 6 + t * 3, CY + 1.5 + t * 2.5, 0.3, 1 } end
for _, s in ipairs(samples) do
  for dy = 0, 1 do for dx = 0, 1 do
    if true then local x, y = floor(s[1] + dx + .5), floor(s[2] + dy + .5)
      coil:set(x, y) cang[K(x, y)] = { s[3], s[4], dx, dy } end
  end end
end

-- leaf tone with AO + cast shadows
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, coil, 1, -1) A.cast(bias, lm, coil, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- curved pinnate veins swept toward the tip
  local ph = (t * len - abs(s) ^ 1.4 * 7.0) / 6.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.78 and t > 0.06 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  -- glossy band on the lit half
  if s < -0.3 and s > -0.42 and t > 0.3 and t < 0.6 then c:put(x, y, LEAF[6], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- red petiole stub at the torn base
for _, q in ipairs{ {54, 47, 3}, {55, 48, 2} } do if not lm:has(q[1], q[2]) then c:put(q[1], q[2], RED[q[3]], ltok) end end

-- sprout from the left seed: juicy red stem, round cotyledons, toothed oval true leaf
local stok = { r = { name = "stem" } }
local sp = { { 19, 42 }, { 17, 34 }, { 22, 26 }, { 20, 18 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - t * 0.2 end)
sm:cut(seeds[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), RED, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function blade2(ax, ay, cx, cy, bx, by, w, teeth, shape)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ (shape or 0.5))
  end, { fold = 0.3 })
  m:cut(sm)
  if teeth then
    local ct = {}
    m:each(function(x, y) local k = K(x, y)
      local ph = (T[k] * L / 2.0 + (S[k] > 0 and 0.5 or 0)) % 1
      if abs(S[k]) > 0.78 and ph < 0.4 and T[k] > 0.25 and T[k] < 0.9 then ct[#ct + 1] = k end end)
    for _, k in ipairs(ct) do m.s[k] = nil end
  end
  A.toneN(c, m, n, SPR, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and SPR[6] or SPR[3], ltok) end end)
  return m
end
blade2(20, 25, 15, 23, 11, 25, 2.6, false, 0.35)   -- left cotyledon (round)
blade2(22, 25, 27, 22, 31, 24, 2.6, false, 0.35)   -- right cotyledon
blade2(20, 19, 23, 13, 29, 7, 3.6, true, 0.7)      -- true leaf
-- red midrib line on the true leaf base (petiole)
c:put(20, 18, RED[3], stok) c:put(21, 17, RED[2], stok)

-- coil: straw valve with a red inner face, lit upper-left
local ctok = { r = { name = "coil" } }
coil:each(function(x, y) local k = K(x, y) local q = cang[k]
  local nx, ny = x - CX, y - CY
  local l = sqrt(nx * nx + ny * ny) + 0.01
  local d = -(nx / l) * 0.6 - (ny / l) * 0.8      -- facing the light
  local i = d > 0.45 and 4 or d > -0.1 and 3 or d > -0.6 and 2 or 1
  if q[3] + q[4] > 1 then i = max(1, i - 1) end    -- lower-right side of the strip is shaded
  local col = POD[i]
  if q[2] > 0.3 and q[2] < 0.95 and i <= 2 then col = (i == 1) and RED[1] or RED[2] end
  c:put(x, y, col, ctok)
end)
c:put(CX, CY, POD[1], ctok)

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  A.toneN(c, s.m, s.n, SEED, { bias = sb, tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.08, wrap = 0.2 })
  -- cool reflected light on the lower-right rim
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.55 then c:put(x, y, "#6a4a5a", tok) end end)
  -- pale hilum dash and a cream glint
  c:put(s[1] + 1, s[2] + 1, SEED[5], tok)
  c:put(s[1] - 1, s[2] - 1, "#fff4d6", tok)
end

A.save(c, NAME)
