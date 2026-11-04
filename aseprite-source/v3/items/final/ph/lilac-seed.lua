-- lilac-seed (final, Opus single pass). Two flat winged lilac seeds (dark embryo body, pale papery wing rim) and a third,
-- germinated seed on a torn heart-shaped lilac leaf scrap (pinnate veins, V-fold light, torn fibrous end, AO + contact
-- shadow). Sprout: slim stem, two round cotyledons and a first opposite pair of heart-shaped true leaves.
-- quirk: a single fallen four-petal lilac floret rests on the leaf tip.
local NAME = "lilac-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF, VEIN, COOL, SEED, STEM = A.LEAF, A.VEIN, A.COOL, A.SEED, A.STEM
local LIL = { "#3a2457", "#583a85", "#7a56b0", "#9a78d0", "#bea0e6", "#e6d6f7" }

-- seeds: cx, cy, rx, ry, ang
local seeds = { { 18, 47, 5.4, 2.4, -0.3 }, { 29, 49, 5.2, 2.3, 0.22 }, { 40, 44, 4.6, 2.2, -1.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf scrap: ovate lilac leaf, tip at left, broad base at right torn off
local lm, ln, LT, LS, len = A.blade(6, 50, 30, 38, 58, 50, function(t)
  if t < 0.015 then return -1 end
  return max(0.4, 8.2 * sin(pi * min(1, 0.06 + t * 0.78)) ^ 0.75)
end, { fold = 0.36 })
local tornE = A.tear(lm, LT, LS, len, 6, "end", 7)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.04 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- pinnate veins: arcs sweeping to the tip
  local ph = (t * len + abs(s) * 5.5) / 6.5 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.15 and abs(s) < 0.78 and t > 0.08 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 and not tornE:has(x, y) then c:put(x, y, COOL, ltok) end end)
tornE:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and LEAF[4] or "#cfe6a0", ltok) end)

-- sprout (behind the third seed's coat)
local stok = { r = { name = "stem" } }
local sp = { { 40, 42 }, { 41, 35 }, { 39, 28 }, { 40, 19 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: small round paddles
local function paddle(x, y, ang, ra, rb)
  local ux, uy = cos(ang), sin(ang)
  local m = A.rell(x + ux * ra, y + uy * ra, ux, uy, ra, rb)
  m:cut(sm)
  local n = X.pillow(m, 1.6)
  A.shade(c, m, n, LEAF, { tok = ltok })
  return m, ux, uy
end
local cl = paddle(39, 31, pi + 0.35, 3.6, 2.0)
local cr = paddle(41, 31, -0.35, 3.6, 2.0)
-- true leaves: an opposite pair of heart-shaped leaves (cordate base, pointed tip, midrib)
local function heart(bx, by, tx, ty, W)
  local cx, cy = (bx + tx) / 2 + (ty - by) * 0.12, (by + ty) / 2 - (tx - bx) * 0.12
  local m, n, T, S = A.blade(bx, by, cx, cy, tx, ty, function(t)
    if t > 0.985 then return -1 end
    return max(0.3, W * sin(pi * (0.22 + 0.78 * t)) ^ 0.65 * (1.1 - 0.35 * t))
  end, { fold = 0.4 })
  m:cut(sm)
  A.shade(c, m, n, LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
heart(39, 20, 28, 12, 3.6)
heart(41, 20, 52, 13, 3.6)
-- terminal bud
c:put(40, 18, STEM[3], stok) c:put(40, 17, STEM[4], stok) c:put(41, 18, STEM[2], stok)

-- seeds last: winged papery rim, dark embryo body with a lit ridge
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.1, wrap = 0.3 }), SEED, { cuts = A.CUTS, bias = sb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local q = u * u + v * v * 1.6
    local i2 = idx[k]
    if q > 0.62 then i2 = i2 + 1                      -- papery wing: paler
    else i2 = i2 - 2 end                              -- embryo body: darker
    if q < 0.62 and q > 0.4 then i2 = i2 - 1 end      -- body rim groove
    if q < 0.12 then i2 = i2 + 2 end                  -- lit ridge
    A.rp(c, x, y, SEED, i2, tok)
  end)
end
-- glint on the front seed's ridge
c:put(28, 48, A.CREAM, { r = { name = "seed2" } })

-- quirk: fallen lilac floret on the leaf tip (4 petals, pale eye)
local ftok = { r = { name = "floret" } }
local fx, fy = 13, 51
for _, p in ipairs{ { 0, -2, 5 }, { -1, -2, 6 }, { -2, 0, 5 }, { -2, -1, 6 }, { 2, 0, 3 }, { 2, 1, 2 }, { 0, 2, 3 }, { 1, 2, 2 },
  { -1, -1, 4 }, { 1, -1, 4 }, { -1, 1, 4 }, { 1, 1, 3 }, { 0, -1, 4 }, { -1, 0, 4 }, { 1, 0, 3 }, { 0, 1, 3 } } do
  A.rp(c, fx + p[1], fy + p[2], LIL, p[3], ftok)
end
c:put(fx, fy, "#f5d76e", ftok)
c:put(fx + 2, fy + 2, LEAF[1], ltok) c:put(fx + 3, fy + 1, LEAF[1], ltok)

A.save(c, NAME)
