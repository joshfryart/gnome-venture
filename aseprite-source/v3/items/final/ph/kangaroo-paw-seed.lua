-- kangaroo-paw-seed (final pass, Opus single pass). Four small angular kangaroo-paw seeds (charcoal-brown, faceted,
-- rough coat with pale grit and one glint each) on a torn strip of the plant's strap leaf (grey-green, parallel
-- veins and no midrib, ragged tears at both ends, cool rim, AO + contact shadow). One seed has sprouted the way a
-- monocot does: a pale foot and two long, slim, upright sword leaves with a fold line, curving apart.
-- quirk: a fallen fuzzy red kangaroo-paw flower lies on the strip, its green claw tips splayed like a little paw.
local NAME = "kangaroo-paw-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#183038", "#244a44", "#33664c", "#4a8458", "#6ea270", "#a2c896" }
local COOL, TISSUE = "#4a7488", "#d6e8be"
local SEED = { "#1a1418", "#2c2226", "#43343a", "#5e4c4c", "#82706a", "#b4a294" }
local SPR = { "#235040", "#35704a", "#4e9254", "#74b464", "#a6d488", "#d8f0b4" }
local FUR = { "#4a1424", "#7e1c2a", "#b42a30", "#dc4a3a", "#f47a52", "#ffb48a" }
local CLAW = { "#2c5034", "#4a7a3e", "#7aa64e", "#b4d27a" }

-- strap leaf strip: long, narrow, near-constant width, rising to the right, torn at both ends
local lm, ln, LT, LS, len = A.blade(6, 57, 30, 54, 58, 42, function(t)
  return 5.0 - 0.8 * t
end, { fold = 0.22 })
local tornR = A.tear(lm, LT, LS, 0.93, { 0.03, -0.02, 0.04, -0.03, 0.05, -0.01, 0.02, 0 })
local tornL = A.tear(lm, LT, LS, 0.05, { -0.02, 0.03, -0.01, 0.04, -0.03, 0.02, 0.0, 0 }, true)
local torn = tornR:copy():add(tornL)

local seeds = { { 18, 53, 2.6, 1.6, -0.3 }, { 25, 51, 2.3, 1.5, 0.5 }, { 33, 50, 2.6, 1.5, -0.15 }, { 40, 46, 2.3, 1.6, -0.9 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7)
  -- facets: clip one corner per seed so they read angular
  local ux, uy = cos(s[5]), sin(s[5])
  local fx, fy = floor(s[1] + ux * s[3] + 0.5), floor(s[2] + uy * s[3] - 1 + 0.5)
  s.m.s[K(fx, fy)] = nil
end
-- fallen flower (quirk): curved fuzzy tube lying on the strip, claw tips at the open end
local fm, fn, FT, FS = A.tube({ { 46, 48 }, { 49, 45 }, { 51, 41 }, { 51, 37 } }, function(t) return 1.3 + 0.5 * t end)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, fm, 1, -1) A.cast(bias, lm, fm, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, cool = COOL, len = len, torn = torn, tissue = TISSUE, tok = ltok,
  bias = bias, midrib = false, veins = false, amb = 0.18 })
-- parallel veins along the strap
lm:each(function(x, y) local k = K(x, y) local s = LS[k]
  if (bias[k] or 0) < 0 or torn:has(x, y) then return end
  if abs(s - 0.35) < 0.08 or abs(s + 0.35) < 0.08 then c:put(x, y, LEAF[max(1, (lidx[k] or 3) - 1)], ltok)
  elseif abs(s + 0.05) < 0.06 then c:put(x, y, LEAF[min(6, (lidx[k] or 4) + 1)], ltok) end
end)

-- sprout from seed 1: two sword leaves
local stok = { r = { name = "sprout" } }
local function sword(p, w)
  local m, n, T, S = A.tube(p, function(t) return w * (1 - t ^ 3) + 0.35 end)
  return m, n, T, S
end
local s1m, s1n, S1T, S1S = sword({ { 18, 51 }, { 16, 40 }, { 15, 28 }, { 13, 14 } }, 1.25)
local s2m, s2n, S2T, S2S = sword({ { 19, 51 }, { 21, 42 }, { 25, 34 }, { 30, 24 } }, 1.15)
s1m:cut(seeds[1].m) s2m:cut(seeds[1].m)
local sb = {}
X.ao(sb, s1m, s2m, 1, -1)
local i1 = A.shade(c, s1m, s1n, SPR, { tok = stok, bias = sb, amb = 0.12, wrap = 0.3 })
local i2 = A.shade(c, s2m, s2n, SPR, { tok = stok, amb = 0.12, wrap = 0.3 })
-- fold line along each blade, pale foot
for _, b in ipairs{ { s1m, S1T, S1S }, { s2m, S2T, S2S } } do
  b[1]:each(function(x, y) local k = K(x, y)
    if abs(b[3][k]) < 0.15 and b[2][k] > 0.1 and b[2][k] < 0.8 then c:put(x, y, SPR[5], stok) end
    if b[2][k] < 0.07 then c:put(x, y, SPR[6], stok) end
  end)
end

-- fallen flower: red fur, white-ish fuzz tips, claw tips
do local tok = { r = { name = "flower" } }
  local idx = A.shade(c, fm, fn, FUR, { tok = tok, amb = 0.1, wrap = 0.25 })
  -- fuzz: alternating light flecks along the lit side, dark flecks on the shade side
  fm:each(function(x, y) local k = K(x, y)
    if (x + y) % 2 == 0 and FS[k] < -0.3 then c:put(x, y, FUR[min(6, idx[k] + 1)], tok) end
    if (x * 2 + y) % 3 == 0 and FS[k] > 0.4 then c:put(x, y, FUR[max(1, idx[k] - 1)], tok) end
  end)
  -- stalk end (base) dark, and splayed claw tips at the open end (top)
  c:put(46, 49, FUR[1], tok) c:put(45, 49, FUR[2], tok)
  local claws = { { 49, 35, 48, 33 }, { 51, 35, 51, 32 }, { 53, 35, 54, 33 } }
  for _, q in ipairs(claws) do
    c:put(q[1], q[2], CLAW[2], tok) c:put(q[3], q[4], CLAW[3], tok)
    c:put(floor((q[1] + q[3]) / 2 + 0.5), floor((q[2] + q[4]) / 2 + 0.5), CLAW[3], tok)
  end
  c:put(48, 33, CLAW[4], tok)
  c:put(50, 36, CLAW[1], tok) c:put(52, 36, CLAW[1], tok)
  local gx, gy = A.specAt(fm, fn, 30) if gx then c:put(gx, gy, FUR[6], tok) end
end

-- seeds: faceted charcoal, grit flecks, one glint
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local b = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(b, s.m, seeds[j].m, 1, -1) end
  if i == 1 then X.ao(b, s.m, s1m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = b, amb = 0.08, wrap = 0.2, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 } })
  vis:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, i) > 0.82 and idx[k] >= 3 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end end)
  -- facet ridge: one lighter diagonal row through the centre
  local ux, uy = cos(s[5] + 1.2), sin(s[5] + 1.2)
  for t = -1, 0 do local x, y = floor(s[1] + ux * t + 0.5), floor(s[2] + uy * t + 0.5)
    if vis:has(x, y) then c:put(x, y, SEED[5], tok) end end
  local gx, gy = A.specAt(vis, s.n, 30) if gx then c:put(gx, gy, "#fff4d6", tok) end
end
c:put(18, 51, SPR[4], stok)

A.save(c, NAME)
