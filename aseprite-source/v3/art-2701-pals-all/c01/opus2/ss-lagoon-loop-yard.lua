-- Lagoon Loop (ss-lagoon-loop), yard sprite 64x64. Opus second pass (art-2701-pals-all/c01/opus2), from the Haiku idea.
-- Seedkeeper, uncommon, Sunsprinkle. "A hole in the picture where a lagoon winks."
-- A plump sand-gold ring (rounded like a tube, sand grain and two tiny shells) that sits on two sandy feet.
-- The hole is a real little lagoon: deep teal at the back, shallow aqua at the front, a foam line on the wet
-- inner rim, and a cross-shaped sun glint that winks off the water. The face sits on the thick lower band.
-- Fixes: hole is bigger and reads as water with depth, the ring has a tube form (not a flat disc).
-- quirk: a tiny sand islet with one palm in the middle of the lagoon.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-lagoon-loop-yard", 64)

local SAND = { "#6e4038", "#a3663e", "#cf9450", "#e8bd6a", "#f4da94", "#fbf0c4" }
local SEA  = { "#1d3f63", "#22607e", "#2b8a9c", "#46b8b8", "#86dccc", "#cff4e4" }
local PALM = { "#1f4a3c", "#2f7a46", "#58a850", "#94d066" }
local WOOD = { "#4a2c2a", "#7a4a34", "#a8744a" }

c:groundShadow(32, 57, 20, 3)
for _, fx in ipairs({ 24, 40 }) do
  O.shade(c, c:ellipse(fx, 54, 4, 2.5), SAND, { R = 1, amb = .25, sep = SAND[1], rim = true })
end

-- the ring
local outer = c:ellipse(32, 32, 22, 21)
local hole = c:ellipse(32, 27, 12, 10)
local ring = outer:copy():cut(hole)
local rb = {}
ring:each(function(x, y)
  if y > 49 then rb[K(x, y)] = -1 end
  if hole:has(x, y - 1) or hole:has(x, y - 2) then rb[K(x, y)] = (rb[K(x, y)] or 0) - 1 end -- inner lower lip in shadow
end)
local rI, rT = O.shade(c, ring, SAND, { R = 7, bias = rb, amb = .06, wrap = .28, sep = SAND[1], rim = true, bounce = "#6f9ab0", bmax = 2 })
-- sand grain: light and dark flecks, kept off the face
O.tex(c, rI, rT, SAND, function(x, y, i)
  local face = x > 20 and x < 44 and y > 38 and y < 50
  local h = H(x, y, 7)
  if h > (face and .99 or .9) and i >= 2 and i <= 5 then return 1 end
  if h < (face and .01 or .07) and i >= 3 then return -1 end
end)
-- two tiny shells
O.dots(c, { { 15, 24 }, { 16, 24 }, { 15, 25 } }, "#f7a8a8") O.dot(c, 16, 25, "#c94f6d") O.dot(c, 15, 24, "#fcd6c8")
O.dots(c, { { 48, 40 }, { 49, 40 } }, "#e8d8ff") O.dots(c, { { 48, 41 }, { 49, 41 } }, "#a090c8")

-- the lagoon in the hole: deep at the back, shallow at the front
hole:each(function(x, y)
  local t = (y - 17) / 20
  local i = 2
  if t > .25 then i = 3 end
  if t > .5 then i = 4 end
  if t > .72 then i = 5 end
  if y <= 18 then i = 1 end -- shade under the far inner lip
  if (y == 24 or y == 29) and H(x, y, 3) > .55 and i >= 3 then i = i + 1 end -- ripple lines
  c:put(x, y, SEA[i], { r = { name = "sea" } })
end)
-- wet inner rim + foam line along the near edge
local hEdge = hole:edge()
hEdge:each(function(x, y)
  if y > 29 then c:put(x, y, SEA[6], { r = { name = "foam" } }) end
end)
for x = 22, 42 do -- wet sand just under the foam
  for y = 33, 40 do
    if ring:has(x, y) and hole:has(x, y - 1) then c:put(x, y, SAND[2], rT) break end
  end
end

-- quirk: palm islet
local isl = c:ellipse(29, 28, 3.5, 1.2)
O.shade(c, isl, SAND, { R = 1, amb = .45, cuts = { .2, .38, .55, .71, .86 } })
O.dots(c, { { 26, 29 }, { 27, 29 }, { 28, 29 }, { 29, 29 }, { 30, 29 }, { 31, 29 }, { 32, 29 } }, SEA[6])
O.dots(c, { { 29, 26 }, { 29, 25 }, { 30, 24 }, { 30, 23 }, { 31, 22 } }, WOOD[2]) O.dots(c, { { 30, 25 }, { 31, 23 } }, WOOD[3])
O.dots(c, { { 28, 21 }, { 29, 21 }, { 30, 21 }, { 27, 22 }, { 26, 23 } }, PALM[3])
O.dots(c, { { 32, 21 }, { 33, 21 }, { 34, 22 }, { 35, 23 } }, PALM[2])
O.dots(c, { { 31, 20 }, { 30, 20 }, { 32, 20 } }, PALM[4]) O.dot(c, 31, 21, PALM[1])
O.dots(c, { { 30, 22 } }, "#7a4a34") -- coconut

-- the wink: a sun glint on the water
for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do O.dot(c, 37 + d[1], 24 + d[2], SEA[6]) end
O.dot(c, 37, 24, "#fdf6dc")

-- face on the lower band
c:eyeLocked(23, 40)
c:eyeLocked(36, 40)
c:cheek(20, 46) c:cheek(42, 46)
O.dots(c, { { 29, 46 }, { 30, 47 }, { 31, 47 }, { 32, 47 }, { 33, 47 }, { 34, 46 } }, P.ink)
O.dots(c, { { 31, 48 }, { 32, 48 } }, "#c94f6d")

O.done(c, "ss-lagoon-loop-yard")
