-- milkweed-seed (final, Opus single pass). Two flat teardrop milkweed seeds (rich brown body, raised centre ridge,
-- pale papery wing rim) on a torn scrap of a broad, blue-green milkweed leaf (thick and waxy: pale cream-pink
-- midrib, near-perpendicular side veins, waxy bloom on the lit half, contact shadow under each seed). The left seed
-- has sprouted: a slim stem with an opposite pair of broad oval milkweed leaves and a tiny bud between them.
-- quirk: a third seed is already drifting away on its open silk parachute, top right.
local NAME = "milkweed-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local LEAF = { "#18363e", "#22524e", "#33705c", "#4c8c68", "#74ac7e", "#a8cc9c" }
local BLOOM = "#c4dcc0"
local RIB, RIB2 = "#f0dcc4", "#c8a898"
local SEED = { "#2e1a18", "#4c2a20", "#70402a", "#965a34", "#bc7c46", "#e0a464" }
local WING = { "#a07650", "#cca476", "#ead0a2" }
local SILK = { "#8e9ac0", "#b4bedc", "#d6dcee", "#eef0f8", "#fbf8f0" }
local STEM = { "#2a5a44", "#4a8a5a", "#7cb274", "#b2d69a" }

-- flat seeds: cx, cy, rx, ry, ang (tip toward +u)
local function seedMask(cx, cy, rx, ry, ang)
  local m = HP.mask()
  local ca, sa = cos(ang), sin(ang)
  for y = floor(cy - 7), floor(cy + 7) do for x = floor(cx - 7), floor(cx + 7) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa)
    local v = (-dx * sa + dy * ca)
    local rr = ry * (u > 0 and (1 - 0.55 * (u / rx) ^ 2) or 1)     -- teardrop: narrows toward the tip
    if (u / (rx + 0.4)) ^ 2 + (v / (rr + 0.4)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local seeds = { { 19, 45, 4.6, 3.2, 0.25 }, { 32, 48, 4.6, 3.2, -0.15 }, { 47, 23, 3.4, 2.4, -0.9 } }
for _, s in ipairs(seeds) do s.m = seedMask(s[1], s[2], s[3], s[4], s[5]) end

-- silk parachute for seed 3: a fan of fine strands from the seed tip, feathered outer edge
local tx, ty = seeds[3][1] + cos(seeds[3][5]) * 2.4, seeds[3][2] + sin(seeds[3][5]) * 2.4
local fm, FA, FR = HP.mask(), {}, {}
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - tx, y - ty
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  local a0, a1 = -2.25, -0.15
  if a >= a0 and a <= a1 and r >= 1 then
    local f = (a - a0) / (a1 - a0)
    local lim = 9.5 + 1.6 * sin(f * pi) + 1.4 * X.hash(floor(f * 14), 3, 5)
    if r <= lim then fm:set(x, y) FA[K(x, y)] = f FR[K(x, y)] = r / lim end
  end
end end

-- leaf scrap: broad blade, torn base on the left
local lm, ln, LT, LS, len = G.blade(9, 50, 29, 40, 55, 46, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 7.6 * sin(pi * min(1, 0.22 + t * 0.8)) ^ 0.75)
end, { fold = 0.45 })
A.tear(lm, LT, LS, len, true, false, 23)
local bias = {}
for i = 1, 2 do local s = seeds[i] X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { tok = ltok, bias = bias, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
local PER = 4.6
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.1 and t < 0.95 then c:put(x, y, RIB, ltok) return end
  if abs(s) < 0.2 and t < 0.92 and s > 0 then c:put(x, y, RIB2, ltok) return end
  -- side veins: nearly perpendicular, curving toward the tip at the margin
  local ph = (t * len - abs(s) ^ 2 * 3.0) / PER
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.86 and t > 0.04 and t < 0.88 then
    c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok)
  elseif s < -0.3 and s > -0.75 and (lidx[k] or 0) >= 5 and X.hash(x, y, 9) > 0.72 then
    c:put(x, y, BLOOM, ltok)                                 -- waxy bloom flecks on the lit half
  end
end)
-- cool reflected edge on the lower margin
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 and LT[k] < 0.85 then c:put(x, y, "#3a6a7a", ltok) end end)

-- sprout from seed 1: slim stem, opposite pair of broad oval leaves, bud
local stok = { r = { name = "sprout" } }
local sm, sn = A.tube({ { 17, 44 }, { 15, 35 }, { 18, 27 }, { 17, 20 } }, function(t) return 1.1 - 0.2 * t end)
sm:cut(seeds[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function oleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, 0.12 + t * 0.9)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  local b = {}
  X.ao(b, m, sm, 1, -1)
  G.toneN(c, m, n, LEAF, { tok = ltok, bias = b, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if not b[k] and abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and RIB or RIB2, ltok) end
  end)
  return m
end
oleaf(16, 22, 10, 17, 7, 22, 3.0)
oleaf(18, 22, 25, 16, 30, 21, 3.0)
local bm = c:ellipse(17, 18, 1, 1.2)
bm:cut(sm)
X.tone(c, bm, X.light(X.sphere(17, 18, 1.4, bm), { amb = 0.2 }), { "#7a3a4a", "#b4607a", "#e0a0b4" }, { cuts = { 0.4, 0.7 }, tok = stok })

-- silk parachute (behind seed 3)
local ftok = { r = { name = "silk" } }
fm:each(function(x, y) local k = K(x, y)
  local f, r = FA[k], FR[k]
  local strand = (floor(f * 22) % 2 == 0)
  local i = 3 + (strand and 1 or 0)
  if f > 0.62 then i = i - 1 end                              -- lower-right fan is the shade side
  if r > 0.86 then i = i + 1 end                              -- bright frayed tips
  if r < 0.25 then i = i - 1 end                              -- AO near the seed
  c:put(x, y, SILK[max(1, min(5, i))], ftok)
end)

-- seeds last: lit flat body, raised ridge, wing rim
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local n = X.pillow(s.m, 1.6)
  local body = s.m:copy()
  local rim = s.m:edge()
  body:cut(rim)
  G.toneN(c, body, n, SEED, { tok = tok, cuts = { 0.15, 0.32, 0.5, 0.68, 0.84 }, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  body:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(v) < 0.55 and u > -s[3] + 1.5 and u < s[3] - 1 then c:put(x, y, v <= 0 and SEED[6] or SEED[3], tok) end
  end)
  rim:each(function(x, y)
    local lit = (x - s[1]) + (y - s[2]) < 0
    c:put(x, y, lit and WING[3] or WING[1], tok)
  end)
  -- one glint
  local gx, gy = floor(s[1] - cos(s[5]) * 1.5 - 1 + 0.5), floor(s[2] - 1 + 0.5)
  if i < 3 and body:has(gx, gy) then c:put(gx, gy, A.CREAM, tok) end
end
-- short silk tuft still tucked at seed 2's tip
for _, p in ipairs { { 37, 47, 4 }, { 38, 47, 5 }, { 39, 46, 4 }, { 38, 46, 3 }, { 40, 46, 5 }, { 37, 46, 3 } } do
  c:put(p[1], p[2], SILK[p[3]], { r = { name = "tuft" } })
end

G.save2(c, NAME)
