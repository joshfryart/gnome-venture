-- Calabash Cup (gc-calabash-cup), yard sprite 64x64. Opus richness pass (c04/opus3), built on c04/opus2.
-- Richness pass: hue-shifted gourd ramp, faint lengthwise ribs following the round belly, mottled rind flecks, a
-- richer pyrographed band (double line, filled triangles, dot row), fibrous cut rim with the inner wall showing
-- behind the water, a glint on the pool, leaf veins and a drop resting on the bowing seedling. Closer look: an old
-- crack low on the left, mended with twine stitches the way real calabashes are repaired.
-- Seedkeeper, common, Great Canopy. "A gourd that catches roof rain and passes it along politely."
-- A round calabash bowl cut open at the top: pale cut rim, a pool of rainwater inside with a ripple ring where a
-- drop just landed, a pyrographed zigzag band round the belly, two stubby feet, the face on the upper belly.
-- Fixed from Haiku: the plain orange pear with a knob read as a generic fruit; now the open cup, the water and the
-- carved band say "calabash". The stray blue bead became a real rain drop with a job.
-- quirk: it tips a polite trickle over its lip into a seedling at its foot, which bows.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("gc-calabash-cup-yard", 64)

local GOURD = { "#45202c", "#7a3e2a", "#a8642e", "#cf9242", "#e8bc66", "#f8e2a2" }
local TWINE = { "#6a4a3a", "#b49470", "#e2cfa8" }
local FLESH = { "#a8804e", "#c9a46a", "#e8d29a", "#f6ead0" }
local WATER = { "#25607a", "#2f8a9a", "#4fb4b4", "#86d6c8", "#c4eedd" }
local LEAF  = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070" }
local BURN  = "#5a2e22"

c:groundShadow(30, 58, 20, 2.5)

-- feet
for _, fx in ipairs({ 22, 37 }) do O.shade(c, c:ellipse(fx, 56, 4, 2), GOURD, { R = 1, amb = .25 }) end

-- bowl body, cut flat at the top
local TOP = 27
local body = c:ellipse(30, 39, 21, 17)
body:cut(c:rect(0, 0, 63, TOP - 1))
local bI, bT = O.shade(c, body, GOURD, { sphere = { 24, 32, 28 }, amb = .2, wrap = .5, rim = true, bounce = "#7a6aa0", bmax = 2, sep = GOURD[1] })
-- lengthwise ribs following the round belly, mottled flecks
O.tex(c, bI, bT, GOURD, function(x, y, i)
  local ry = (y - 39) / 17
  local w = 21 * math.sqrt(math.max(.05, 1 - ry * ry))
  local u = math.max(-1, math.min(1, (x - 30) / w))
  local lon = math.asin(u) / math.pi * 8
  if math.abs(lon - math.floor(lon + .5)) < .11 and i >= 2 and y < 44 and not (y > 31 and y < 42 and x > 16 and x < 42) then return -1 end
  if H(x, y, 9) > .93 and i >= 3 then return -1 end
  if H(x, y, 4) > .95 and i >= 2 and i <= 4 then return 1 end
end)

-- pyrographed band low on the belly: two burnt lines with a row of hanging triangles
for x = 9, 51 do
  O.mark(c, { { x, 44 } }, BURN)
  local k = (x - 9) % 6
  if k <= 4 then O.mark(c, { { x, 45 } }, BURN) end
  if k >= 1 and k <= 3 then O.mark(c, { { x, 46 } }, BURN) end
  if k == 2 then O.mark(c, { { x, 47 } }, BURN) end
  O.mark(c, { { x, 49 } }, BURN)
  if x % 3 == 0 then O.mark(c, { { x, 51 } }, BURN) end
end
-- cut rim (pale flesh ring) and the rainwater inside
local mouth = c:ellipse(30, TOP + .5, 19, 4.5)
mouth:cut(c:rect(0, TOP + 5, 63, 63))
local rim = HP.mask()
mouth:each(function(x, y) rim:set(x, y) end)
rim:each(function(x, y)
  local dx = (x - 30) / 19
  c:put(x, y, (dx < -.2) and FLESH[4] or (dx < .5 and FLESH[3] or FLESH[2]), bT)
end)
local pool = c:ellipse(30, TOP + 1, 16.5, 3)
local pv = {}
pool:each(function(x, y) pv[K(x, y)] = .25 + (y - TOP + 2) * .12 + ((x < 26) and .15 or 0) end)
X.tone(c, pool, pv, WATER, { cuts = { .3, .5, .7, .85 } })
-- ripple ring where a drop just landed
O.dots(c, { { 33, 27 }, { 34, 26 }, { 35, 26 }, { 36, 26 }, { 37, 27 }, { 34, 28 }, { 35, 28 }, { 36, 28 } }, WATER[5])
O.dot(c, 35, 27, WATER[2])
-- fibrous cut edge: a few darker fibre ticks in the pale rim
O.mark(c, { { 14, 28 }, { 19, 30 }, { 25, 31 }, { 34, 31 }, { 41, 30 }, { 46, 28 } }, FLESH[2])
-- a glint on the pool
O.dots(c, { { 20, 28 }, { 21, 28 }, { 22, 28 } }, WATER[5])
-- dark inner shadow under the back lip
for x = 15, 45 do if pool:has(x, TOP - 1) then O.mark(c, { { x, TOP - 1 } }, WATER[1]) end end

-- quirk: the polite trickle over the right lip into a bowing seedling
local tr, tn = O.tube({ { 47, 28 }, { 51, 28 }, { 53, 32 }, { 53, 45 } }, function(t) return 1 - t * .3 end)
O.shadeN(c, tr, tn, WATER, { amb = .4, wrap = .5, cuts = { .3, .5, .7, .85 } })
O.dots(c, { { 53, 47 }, { 53, 48 } }, WATER[3])
local stem = O.tube({ { 54, 57 }, { 54, 54 }, { 55, 52 }, { 57, 51 } }, function() return .7 end)
O.flat(c, stem, LEAF[3], "stem")
local lf1 = c:ellipse(54.5, 50.5, 2.5, 1.3)
local lf2 = c:ellipse(58.5, 52, 2.5, 1.3)
O.shade(c, lf1:add(lf2), LEAF, { R = 1, amb = .35, wrap = .4, sep = LEAF[1] })
O.dots(c, { { 53, 51 }, { 54, 51 }, { 58, 52 }, { 59, 52 } }, LEAF[2]) -- leaf midribs
-- closer look: an old crack low on the left, mended with twine cross-stitches
O.mark(c, { { 13, 33 }, { 13, 34 }, { 12, 35 }, { 12, 36 }, { 13, 37 }, { 13, 38 }, { 12, 39 } }, GOURD[1])
for _, st in ipairs({ { 12, 34 }, { 14, 34 }, { 11, 37 }, { 14, 37 } }) do O.mark(c, { st }, TWINE[3]) end
O.mark(c, { { 11, 36 }, { 13, 36 } }, TWINE[2])

-- face
c:eyeLocked(20, 33)
c:eyeLocked(34, 33)
c:cheek(17, 39) c:cheek(40, 39)
O.dots(c, { { 26, 39 }, { 27, 40 }, { 28, 40 }, { 29, 40 }, { 30, 40 }, { 31, 40 }, { 32, 39 } }, P.ink)

O.shift(c, 0, 0)
O.done(c, "gc-calabash-cup-yard", function(c)
  -- the next rain drop on its way down (not outlined)
  c:put(35, 17, WATER[4]) c:put(35, 18, WATER[4]) c:put(34, 19, WATER[5]) c:put(35, 19, WATER[3]) c:put(36, 19, WATER[3])
  c:put(34, 20, WATER[3]) c:put(35, 20, WATER[2]) c:put(36, 20, WATER[2]) c:put(35, 21, WATER[1])
  -- a drop resting on the seedling's leaf
  c:put(55, 48, WATER[4]) c:put(56, 48, WATER[3])
end)
