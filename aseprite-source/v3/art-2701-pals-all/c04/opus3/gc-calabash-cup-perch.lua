-- Calabash Cup (gc-calabash-cup), perch sprite 36x36. Opus richness pass (c04/opus3), hand-built at this size.
-- Richness pass: hue-shifted gourd ramp, three bold lengthwise ribs, a band of real triangles between two burnt lines,
-- a glint on the water, a seedling with two leaves and a twine-stitched crack (bold, two stitches). From opus2:
-- the open calabash bowl (pale cut rim, rainwater inside), one burnt band of triangles, stubby feet,
-- face high on the belly (2x3 pills, ink smile, cheeks).
-- quirk: the trickle over its right lip into a little seedling.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gc-calabash-cup-perch", 36)

local GOURD = { "#45202c", "#7a3e2a", "#a8642e", "#cf9242", "#e8bc66", "#f8e2a2" }
local FLESH = { "#a8804e", "#c9a46a", "#e8d29a", "#f6ead0" }
local WATER = { "#25607a", "#2f8a9a", "#4fb4b4", "#86d6c8", "#c4eedd" }
local LEAF  = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070" }
local BURN  = "#5a2e22"

c:groundShadow(16, 32, 12, 1.5)
for _, fx in ipairs({ 11, 20 }) do O.shade(c, c:ellipse(fx, 30.5, 2.5, 1.2), GOURD, { R = 1, amb = .25 }) end

local TOP = 14
local body = c:ellipse(16, 21.5, 12.5, 9.5)
body:cut(c:rect(0, 0, 40, TOP - 1))
local bI, bT = O.shade(c, body, GOURD, { sphere = { 12, 17, 16 }, amb = .2, wrap = .5, rim = true, bounce = "#7a6aa0", bmax = 2, sep = GOURD[1] })
O.tex(c, bI, bT, GOURD, function(x, y, i) -- three lengthwise ribs, away from the face
  local ry = (y - 21.5) / 9.5
  local w = 12.5 * math.sqrt(math.max(.05, 1 - ry * ry))
  local lon = math.asin(math.max(-1, math.min(1, (x - 16) / w))) / math.pi * 4
  if math.abs(lon - math.floor(lon + .5)) < .1 and math.abs(math.floor(lon + .5)) == 1 and i >= 2 and (y > 22 or y < 16) then return -1 end
end)
for x = 5, 27 do
  O.mark(c, { { x, 24 } }, BURN) O.mark(c, { { x, 27 } }, BURN)
  local k = (x - 5) % 4
  if k <= 2 then O.mark(c, { { x, 25 } }, BURN) end
  if k == 1 then O.mark(c, { { x, 26 } }, BURN) end
end
-- stitched crack (closer look)
O.mark(c, { { 6, 18 }, { 5, 19 }, { 6, 20 }, { 5, 21 } }, GOURD[1])
O.mark(c, { { 4, 19 }, { 7, 20 } }, "#e2cfa8")

local mouth = c:ellipse(16, TOP + .5, 11.5, 2.5)
mouth:cut(c:rect(0, TOP + 3, 40, 40))
mouth:each(function(x, y) local dx = (x - 16) / 11.5 c:put(x, y, (dx < -.2) and FLESH[4] or (dx < .5 and FLESH[3] or FLESH[2]), bT) end)
local pool = c:ellipse(16, TOP + .5, 9.5, 1.2)
pool:each(function(x, y) c:put(x, y, (y <= TOP) and WATER[2] or (x < 14 and WATER[4] or WATER[3]), bT) end)
O.dots(c, { { 18, 14 }, { 19, 14 } }, WATER[5]) O.dots(c, { { 10, 15 }, { 11, 15 } }, WATER[5])

-- quirk: trickle and seedling
local tr, tn = O.tube({ { 26, 15 }, { 28, 15 }, { 30, 17 }, { 30, 24 } }, function() return .6 end)
O.flat(c, tr, WATER[3], "trickle")
O.dot(c, 30, 26, WATER[3])
O.flat(c, c:rect(31, 29, 31, 31), LEAF[3], "stem")
O.flat(c, c:rect(30, 28, 31, 28), LEAF[4], "leaf") O.flat(c, c:rect(32, 29, 33, 29), LEAF[3], "leaf")

c:eyeSmall(11, 17)
c:eyeSmall(20, 17)
O.dot(c, 9, 20, "#f5809f") O.dot(c, 23, 20, "#f5809f")
O.dots(c, { { 14, 20 }, { 15, 21 }, { 16, 21 }, { 17, 21 }, { 18, 20 } }, P.ink)

O.shift(c, 0, -2)
O.done(c, "gc-calabash-cup-perch", function(c)
  c:put(19, 6, WATER[4]) c:put(19, 7, WATER[3]) c:put(19, 8, WATER[2])
  c:put(32, 26, WATER[4]) -- a drop resting on the seedling
end)
