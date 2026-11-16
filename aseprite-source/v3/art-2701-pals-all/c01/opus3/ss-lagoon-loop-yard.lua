-- Lagoon Loop (ss-lagoon-loop), yard sprite 64x64. Opus third pass (art-2701-pals-all/c01/opus3), richness pass
-- over opus2: the hole now has an inner sand wall (shaded at the top where it turns away from the light, lit on the
-- right), a wet-sand waterline, water bands that follow the bowl, dark coral heads under the surface, caustic
-- ripples and the palm's reflection; wind ripples and pebbles in the sand, toes on the feet, a tiny crab peeking
-- over the right side and a message bottle bobbing beside the islet.
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
  O.mark(c, { { fx - 1, 55 }, { fx + 2, 55 } }, SAND[2])
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
-- wind ripples: short arcs following the ring, darker below a lit crest
for _, a in ipairs({ { 2.35, 19 }, { 2.6, 17.5 }, { 2.05, 20.5 }, { 3.6, 19.5 }, { 3.9, 18 }, { 0.6, 20 }, { 0.25, 18.5 } }) do
  for s = -3, 3 do
    local t = a[1] + s * .055
    local x, y = math.floor(32 + math.cos(t) * a[2] + .5), math.floor(31 - math.sin(t) * a[2] * .95 + .5)
    local k = K(x, y)
    if rI[k] and c.own[y * 64 + x] == rT and not (x > 20 and x < 44 and y > 37) then
      c.pix[y * 64 + x] = SAND[math.max(1, rI[k] - 1)]:lower()
      local k2 = K(x, y - 1)
      if rI[k2] and c.own[(y - 1) * 64 + x] == rT then c.pix[(y - 1) * 64 + x] = SAND[math.min(6, rI[k2] + 1)]:lower() end
    end
  end
end
-- pebbles
O.dots(c, { { 12, 33 } }, "#9a8a9a") O.dot(c, 12, 32, "#cabcc4") O.dots(c, { { 52, 28 } }, "#8a7890")
-- two tiny shells
O.dots(c, { { 15, 24 }, { 16, 24 }, { 15, 25 } }, "#f7a8a8") O.dot(c, 16, 25, "#c94f6d") O.dot(c, 15, 24, "#fcd6c8")
O.dots(c, { { 48, 40 }, { 49, 40 } }, "#e8d8ff") O.dots(c, { { 48, 41 }, { 49, 41 } }, "#a090c8")

-- inner sand wall: the top of the hole shows the ring's inside face
local water = hole:copy():clip(hole:shift(0, 2))
hole:each(function(x, y)
  if not water:has(x, y) then
    local col = (x < 27) and SAND[2] or (x < 36 and SAND[3] or SAND[4])
    if y == 17 or (not hole:has(x, y - 1)) then col = (x < 30) and SAND[1] or SAND[2] end
    c:put(x, y, col, rT)
  end
end)
-- the lagoon: bands follow the bowl (deep in the middle back, shallow toward the near rim)
local ST = { r = { name = "sea" } }
water:each(function(x, y)
  local t = (y - 19) / 18 + .22 * ((x + .5 - 32) / 12) ^ 2
  local i = 2
  if t > .22 then i = 3 end
  if t > .45 then i = 4 end
  if t > .68 then i = 5 end
  if not water:has(x, y - 1) then i = 1 end -- wet shadow line under the inner wall

  c:put(x, y, SEA[i], ST)
end)
-- coral heads under the surface (dark, soft shapes in the deep band)
O.dots(c, { { 23, 26 }, { 24, 26 }, { 24, 25 }, { 25, 26 }, { 39, 28 }, { 40, 28 }, { 40, 27 }, { 41, 28 }, { 35, 31 }, { 36, 31 } }, SEA[2])
O.dots(c, { { 24, 27 }, { 40, 29 } }, "#2a7a8a")
-- caustic ripples in the shallows
O.dots(c, { { 22, 31 }, { 23, 30 }, { 24, 31 }, { 38, 32 }, { 39, 31 }, { 40, 32 }, { 31, 33 }, { 32, 32 }, { 33, 33 } }, SEA[6])
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
local isl = c:ellipse(29, 30, 3.5, 1.2)
O.shade(c, isl, SAND, { R = 1, amb = .45, cuts = { .2, .38, .55, .71, .86 } })
O.dots(c, { { 26, 31 }, { 27, 31 }, { 28, 31 }, { 29, 31 }, { 30, 31 }, { 31, 31 }, { 32, 31 } }, SEA[6])
O.dots(c, { { 29, 28 }, { 29, 27 }, { 30, 26 }, { 30, 25 }, { 31, 24 } }, WOOD[2]) O.dots(c, { { 30, 27 }, { 31, 25 } }, WOOD[3])
O.dots(c, { { 28, 23 }, { 29, 23 }, { 30, 23 }, { 27, 24 }, { 26, 25 } }, PALM[3])
O.dots(c, { { 32, 23 }, { 33, 23 }, { 34, 24 }, { 35, 25 } }, PALM[2])
O.dots(c, { { 31, 22 }, { 30, 22 }, { 32, 22 } }, PALM[4]) O.dot(c, 31, 23, PALM[1])
O.dots(c, { { 30, 24 } }, "#7a4a34") -- coconut
O.dots(c, { { 29, 32 }, { 30, 33 } }, SEA[3]) O.dot(c, 31, 32, PALM[2]) -- the palm's reflection
-- a message bottle bobbing beside the islet
O.dots(c, { { 34, 29 }, { 35, 29 } }, "#7ac8a0") O.dot(c, 36, 29, "#c8a070") O.dot(c, 34, 28, "#c8f0d8") O.dot(c, 35, 30, SEA[6])
-- a tiny crab peeking over the right side
O.flat(c, c:rect(51, 19, 53, 20), "#e05a3a", "crab") O.dot(c, 51, 19, "#f8905a") O.dot(c, 53, 20, "#a83a2e")
O.dots(c, { { 50, 18 }, { 54, 18 } }, "#e05a3a") O.dots(c, { { 51, 17 }, { 53, 17 } }, P.ink)


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
