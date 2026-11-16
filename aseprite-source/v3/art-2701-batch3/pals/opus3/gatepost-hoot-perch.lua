-- Gatepost Hoot (mm-gatepost-hoot), perch sprite 36x36. Opus richness pass (opus3), hand-built at this size.
-- Fix vs opus2: the facial disc is wider (two 4 px lobes) and the pill eyes sit 6 px apart in their own dark
-- sockets with the beak between them, so the owl's eyes read at 1x. Richness, bold and few: rim light on the
-- head, cool bounce lower-right, three crown streaks, a scalloped breast row, post grain + end-grain ring.
-- owl is two thirds of the height so the heart-shaped disc holds clear pill eyes and a 2 px beak;
-- the post is short (ends 3 px above the bottom edge) with a rail stub and hinge.
-- quirk: the wool tuft snagged on the post nail.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local BNC = "#6a5c78"
local c = O.canvas("gatepost-hoot-perch", 36)

local OWL  = { "#33201f", "#563628", "#7c5236", "#a27248", "#c69862", "#e4c28c" }
local FACE = { "#a98a74", "#d2b698", "#ecdabe", "#faefd8" }
local POST = { "#352c30", "#544643", "#76665a", "#978571", "#b8a68c", "#d8c8aa" }
local IRON = { "#2f3044", "#4f5068", "#7a7b92" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local WOOL = { "#c9bfae", "#e6ddcb", "#f7f0e0" }

c:groundShadow(18, 32, 10, 1.5)
-- rail + post
O.shade(c, c:rect(3, 25, 13, 27), POST, { R = 1, amb = .25 })
O.dots(c, { { 3, 25 }, { 3, 26 }, { 3, 27 } }, POST[6])
local post = c:rect(13, 23, 23, 31)
local pb = {}
post:each(function(x, y) if (x == 16 or x == 20) and y % 3 ~= 0 then pb[K(x, y)] = -1 end if y == 23 then pb[K(x, y)] = 2 end end)
O.shade(c, post, POST, { R = 2, bias = pb, amb = .22, wrap = .35, sep = POST[1], rim = true, bounce = BNC, bmax = 2 })
O.mark(c, { { 16, 23 }, { 17, 23 }, { 19, 23 } }, POST[5])
O.flat(c, c:rect(10, 26, 15, 26), IRON[2], "hinge") O.dot(c, 10, 26, IRON[3])
-- quirk: wool on the nail
O.dot(c, 23, 27, IRON[1])
local wool = O.unionCircles{ { 25, 28, 1.5, 1 }, { 26, 29.5, 1.5, 1 } }
O.shade(c, wool, WOOL, { R = 1, amb = .4, cuts = { .4, .7 } })

-- owl
local body = c:ellipse(18, 15, 8.5, 8.5)
body:add(c:poly{ { 10, 5 }, { 14, 8 }, { 11, 11 } })
body:add(c:poly{ { 26, 5 }, { 22, 8 }, { 25, 11 } })
O.shade(c, body, OWL, { sphere = { 15, 11, 11 }, amb = .2, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
O.mark(c, { { 15, 8 }, { 18, 7 }, { 21, 8 } }, OWL[3]) -- crown streaks
local br = c:ellipse(18, 20, 4, 3)
O.shade(c, br, OWL, { R = 2, amb = .5, wrap = .5 })
O.dots(c, { { 15, 21 }, { 17, 21 }, { 19, 21 }, { 21, 21 }, { 16, 22 }, { 20, 22 } }, OWL[3]) -- scallops
for _, w in ipairs({ 10.5, 25.5 }) do
  local wm = c:ellipse(w, 18, 2.5, 5)
  wm:cut(c:rect(0, 0, 35, 13))
  local wb = {} wm:each(function(x, y) wb[K(x, y)] = -1 end)
  O.shade(c, wm, OWL, { R = 1, bias = wb, amb = .25, sep = OWL[1] })
end
O.dot(c, 10, 17, OWL[5]) O.dot(c, 26, 19, OWL[4])

local disc = O.unionCircles{ { 14, 13.5, 4, 3.5 }, { 22, 13.5, 4, 3.5 } }
disc:add(c:poly{ { 11, 15 }, { 25, 15 }, { 18, 20 } })
O.shade(c, disc, FACE, { R = 2, amb = .4, wrap = .45, cuts = { .3, .55, .8 }, sep = OWL[2] })
for _, ex in ipairs({ 13, 22 }) do
  -- dark socket: sides and under the pill, open above so the glint reads
  O.mark(c, { { ex - 1, 13 }, { ex - 1, 14 }, { ex - 1, 15 }, { ex + 2, 13 }, { ex + 2, 14 }, { ex + 2, 15 }, { ex, 16 }, { ex + 1, 16 } }, FACE[1])
  c:eyeSmall(ex, 13)
end
O.mark(c, { { 17, 12 }, { 18, 12 } }, FACE[2]) -- disc ridge between the eyes
O.dot(c, 17, 15, GOLD[4]) O.dot(c, 18, 15, GOLD[3]) O.dot(c, 17, 16, GOLD[3]) O.dot(c, 18, 16, GOLD[2])
O.dot(c, 17, 17, GOLD[2]) O.dot(c, 18, 17, "#6e2c2a")
O.dot(c, 11, 17, "#f5809f") O.dot(c, 25, 17, "#f5809f")
-- talons
O.dots(c, { { 15, 23 }, { 16, 23 }, { 20, 23 }, { 21, 23 } }, GOLD[2]) O.dots(c, { { 15, 23 }, { 20, 23 } }, GOLD[3])

O.shift(c, 2, 0)
O.done(c, "gatepost-hoot-perch")
