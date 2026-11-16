-- Lofty Kite (sp-lofty-kite), yard sprite 64x64. Opus second pass (art-2701-pals-all/c06/opus2), built on the Haiku pass.
-- Rare, wayfinder (shape whimsy-kite). "Flies high over the ridge and always looks down on everything."
-- A tilted diamond kite pal: four cloth panels (sea blue and saffron, alternating), bamboo spars showing
-- through the cloth, a hemmed edge, and a ribbon tail in an S-curve with three bow ties.
-- Fixes vs Haiku: the kite tilts in the wind (was upright and stiff), panels give it a clear two-colour read,
-- the tail is one clean S-curve with bows (was a tangle), the face sits on one big panel area.
-- quirk: it looks down on everything: far below, a tiny snowy ridge, and the kite peers down at it over
-- haughty lowered brows with a smug little smile.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-lofty-kite-yard", 64)

local SEA  = { "#1a2c58", "#24448a", "#2e64b4", "#4a8ad6", "#7cb2ea", "#b8daf8" }
local SAF  = { "#7a3a1a", "#b4601e", "#e48e26", "#f6b442", "#ffd47a", "#fff0bc" }
local BAMB = { "#5a4228", "#8a6a3e", "#b89458", "#dcc184" }
local RIB  = { "#6e1a3a", "#b0305a", "#e05a7e", "#fa9ab0" }
local ROCK = { "#3e3654", "#5e5878", "#8682a0", "#b4b2c6" }
local SNOW = { "#c4cad8", "#e6eaf0", "#f8f8f4" }
local BNC  = "#3a6a7a"

-- the ridge far below (quirk), drawn first and small
local ridge = c:poly{ { 40, 61 }, { 47, 51 }, { 51, 55 }, { 55, 48 }, { 62, 61 } }
local rI, rT = O.shade(c, ridge, ROCK, { R = 2, amb = .3, wrap = .4, cuts = { .3, .55, .8 } })
for _, p in ipairs({ { 47, 51 }, { 46, 52 }, { 47, 52 }, { 48, 52 }, { 46, 53 }, { 48, 53 }, { 55, 48 }, { 54, 49 }, { 55, 49 }, { 56, 49 }, { 53, 50 }, { 54, 50 }, { 55, 50 }, { 56, 50 }, { 57, 50 }, { 53, 51 }, { 55, 51 }, { 57, 51 } }) do
  O.mark(c, { p }, (p[1] <= 55) and SNOW[3] or SNOW[1])
end

-- ribbon tail: S-curve from the bottom corner, with three bows
local function bz3(p, t) return O.bez(p, t) end
local tail = { { 36, 40 }, { 22, 47 }, { 42, 53 }, { 26, 61 } }
local seen = {}
for i = 0, 120 do
  local x, y = bz3(tail, i / 120)
  x, y = math.floor(x + .5), math.floor(y + .5)
  if not seen[K(x, y)] then seen[K(x, y)] = true O.dot(c, x, y, RIB[2]) end
end
local function bow(x, y, R)
  O.shade(c, c:poly{ { x, y }, { x - 4, y - 2 }, { x - 4, y + 2 } }, R, { R = 1, amb = .35, sep = R[1], cuts = { .3, .55, .8 } })
  O.shade(c, c:poly{ { x, y }, { x + 4, y - 2 }, { x + 4, y + 2 } }, R, { R = 1, amb = .2, sep = R[1], cuts = { .3, .55, .8 } })
  O.dot(c, x, y, R[1])
end
for _, t in ipairs({ .3, .62, .94 }) do
  local x, y = bz3(tail, t) bow(math.floor(x + .5), math.floor(y + .5), (t == .62) and { "#7a3a1a", "#e48e26", "#f6b442", "#ffd47a" } or RIB)
end

-- kite body: tilted diamond
local T, R, B, L = { 29, 3 }, { 55, 13 }, { 36, 41 }, { 8, 18 }
local kite = c:poly{ T, R, B, L }
local Cx, Cy = 31, 19 -- spar crossing
local panel = {}
kite:each(function(x, y)
  -- which side of each spar line
  local s1 = (x - T[1]) * (B[2] - T[2]) - (y - T[2]) * (B[1] - T[1])
  local s2 = (x - L[1]) * (R[2] - L[2]) - (y - L[2]) * (R[1] - L[1])
  panel[K(x, y)] = (s2 > 0) and ((s1 > 0) and 1 or 3) or 2
end)
local mA, mB = HP.mask(), HP.mask()
local mC = HP.mask()
kite:each(function(x, y) local q = panel[K(x, y)] if q == 1 then mA:set(x, y) elseif q == 3 then mC:set(x, y) else mB:set(x, y) end end)
local n = X.pillow(kite, 7)
local aI, aT = O.shadeN(c, mA, n, SEA, { amb = .26, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
local bI, bT = O.shadeN(c, mB, n, SAF, { amb = .26, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
local SEA2 = { "#16264a", "#1e3c78", "#2a5aa0", "#3e7cc4", "#6aa2dc", "#a6cef2" }
O.shadeN(c, mC, n, SEA2, { amb = .2, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
-- cloth weave: faint diagonal threads keep the lighting

-- bamboo spars showing through the cloth
local function spar(a, b, hex)
  local d = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]))
  for i = 0, d do
    local x, y = math.floor(a[1] + (b[1] - a[1]) * i / d + .5), math.floor(a[2] + (b[2] - a[2]) * i / d + .5)
    if c:get(x, y) then c.pix[y * c.w + x] = hex end
  end
end
spar({ 29, 4 }, { 31, 16 }, BAMB[2])
spar({ 35, 34 }, { 36, 40 }, BAMB[2])
spar({ 9, 18 }, { 54, 13 }, BAMB[2])
spar({ 28, 5 }, { 29, 11 }, BAMB[4])
spar({ 9, 17 }, { 28, 4 }, SEA[6])

-- face: locked eyes with haughty lowered brows, smug smile
c:eyeLocked(21, 22)
c:eyeLocked(33, 21)
-- haughty half-lids: the top row of each eye is lid (it peers down its nose)
O.mark(c, { { 22, 22 }, { 23, 22 }, { 24, 22 }, { 34, 21 }, { 35, 21 }, { 36, 21 } }, SAF[2])
O.dots(c, { { 20, 22 }, { 21, 21 }, { 22, 21 }, { 23, 21 }, { 24, 21 }, { 25, 22 }, { 32, 21 }, { 33, 20 }, { 34, 20 }, { 35, 20 }, { 36, 20 }, { 37, 21 } }, SAF[1])
O.dots(c, { { 27, 30 }, { 28, 30 }, { 29, 30 }, { 30, 29 }, { 31, 29 } }, P.ink)
c:cheek(18, 28) c:cheek(38, 26)
-- nose-up tie point at the bottom corner
O.dot(c, 36, 40, BAMB[1])

O.done(c, "sp-lofty-kite-yard", function(c)
  -- wind lines (un-outlined)
  for _, p in ipairs({ { 2, 9 }, { 3, 9 }, { 4, 9 }, { 5, 9 }, { 3, 12 }, { 4, 12 }, { 5, 12 }, { 58, 26 }, { 59, 26 }, { 60, 26 }, { 61, 26 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], "#b8daf8") end
  end
end)
