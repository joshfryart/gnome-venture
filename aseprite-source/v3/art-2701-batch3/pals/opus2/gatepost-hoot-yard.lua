-- Gatepost Hoot (mm-gatepost-hoot), yard sprite 64x64. Opus second pass (art-2701-batch3/pals/opus2).
-- Seedkeeper, rare, Mistmoor. "Watches the lane from the gatepost and hoots at the sheep."
-- A round tawny owl sat on top of a weathered gatepost (pale end grain, grain lines, an iron hinge
-- strap and the stub of the gate rail). Ear tufts, a heart-shaped cream facial disc, locked eyes in
-- gold rings, beak open mid-hoot, folded spotted wings, scalloped breast, talons over the post top.
-- quirk: a tuft of sheep's wool snagged on a nail in the post.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gatepost-hoot-yard", 64)

local OWL  = { "#33201f", "#563628", "#7c5236", "#a27248", "#c69862", "#e4c28c" }
local FACE = { "#a98a74", "#d2b698", "#ecdabe", "#faefd8" }
local POST = { "#352c30", "#544643", "#76665a", "#978571", "#b8a68c", "#d8c8aa" }
local IRON = { "#2f3044", "#4f5068", "#7a7b92" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local WOOL = { "#c9bfae", "#e6ddcb", "#f7f0e0" }

c:groundShadow(30, 56, 15, 2.5)

-- gate rail stub going off to the left (behind the post)
local rail = c:rect(6, 45, 26, 49)
local rb = {}
rail:each(function(x, y) if y == 47 and x % 5 ~= 0 then rb[K(x, y)] = -1 end end)
O.shade(c, rail, POST, { R = 2, bias = rb, amb = .25, wrap = .35 })
O.dots(c, { { 6, 45 }, { 6, 46 }, { 6, 47 }, { 6, 48 }, { 6, 49 } }, POST[6]) -- sawn end
-- the post
local post = c:rect(23, 40, 37, 55)
local pb = {}
post:each(function(x, y)
  if (x == 26 or x == 31 or x == 35) and (y * 3 + x) % 7 ~= 0 then pb[K(x, y)] = -1 end
  if y == 40 then pb[K(x, y)] = 2 end
end)
O.shade(c, post, POST, { R = 3, bias = pb, amb = .22, wrap = .35, sep = POST[1] })
-- iron hinge strap across rail + post
O.flat(c, c:rect(18, 46, 28, 47), IRON[2], "hinge")
O.dots(c, { { 18, 46 }, { 19, 46 }, { 20, 46 } }, IRON[3])
O.dots(c, { { 21, 47 }, { 26, 47 } }, IRON[1])

-- quirk: wool snagged on a nail
O.dot(c, 38, 51, IRON[1])
local wool = O.unionCircles{ { 40, 52, 2, 1.5 }, { 42.5, 53.5, 1.5, 1.5 }, { 39.5, 54.5, 1.5, 1 } }
O.shade(c, wool, WOOL, { R = 1, amb = .4, cuts = { .4, .7 } })
O.dot(c, 39, 51, WOOL[3])

-- body (head and body one round mass, owl style)
local body = c:ellipse(30, 28, 13, 13)
-- ear tufts
body:add(c:poly{ { 18, 12 }, { 24, 17 }, { 19, 21 } })
body:add(c:poly{ { 42, 12 }, { 36, 17 }, { 41, 21 } })
local bb = {}
body:each(function(x, y) if y > 33 and (x + y) % 4 == 0 then bb[K(x, y)] = -1 end end)
O.shade(c, body, OWL, { sphere = { 25, 22, 17 }, bias = bb, amb = .2, wrap = .35 })
O.dots(c, { { 19, 13 }, { 41, 13 } }, OWL[6])

-- breast: lighter patch with feather scallops
local br = c:ellipse(30, 35, 7, 5.5)
local brb = {}
br:each(function(x, y) if (y % 3 == 0 and x % 4 == 1) or (y % 3 == 1 and (x % 4 == 0 or x % 4 == 2)) then brb[K(x, y)] = -2 end end)
O.shade(c, br, OWL, { R = 3, bias = brb, amb = .5, wrap = .5 })

-- folded wings, darker, with pale bars
for _, w in ipairs({ { 18.5, 31, -1 }, { 41.5, 31, 1 } }) do
  local wm = c:ellipse(w[1], w[2], 4, 8)
  wm:cut(c:rect(0, 0, 63, 23))
  local wb = {}
  wm:each(function(x, y) wb[K(x, y)] = -1 if (y == 28 or y == 33) and (x + y) % 3 == 0 then wb[K(x, y)] = 1 end end)
  O.shade(c, wm, OWL, { R = 2, bias = wb, amb = .25, sep = OWL[1] })
end

-- heart-shaped facial disc
local disc = O.unionCircles{ { 25.5, 23, 5.5, 5 }, { 34.5, 23, 5.5, 5 } }
disc:add(c:poly{ { 21, 25 }, { 39, 25 }, { 30, 32 } })
O.shade(c, disc, FACE, { R = 3, amb = .4, wrap = .45, cuts = { .3, .55, .8 }, sep = OWL[2] })
-- eyes: locked eyes inside gold rings
for _, ex in ipairs({ 23, 32 }) do
  -- dark feather socket round each eye (the disc's own shade), no ring between the eyes
  local ring = c:ellipse(ex + 2, 23, 3.5, 3.5)
  ring:each(function(x, y) if (ex < 30 and x <= ex + 2) or (ex > 30 and x >= ex + 2) or y > 24 then O.mark(c, { { x, y } }, FACE[1]) end end)
  c:eyeLocked(ex, 21)
end
-- beak, open mid-hoot
O.dots(c, { { 29, 26 }, { 30, 26 }, { 31, 26 } }, GOLD[3]) O.dot(c, 29, 26, GOLD[4])
O.dots(c, { { 29, 27 }, { 31, 27 } }, GOLD[2]) O.dot(c, 30, 27, "#6e2c2a")
O.dot(c, 30, 28, GOLD[1])
c:cheek(20, 28) c:cheek(39, 28)

-- talons gripping the post top
for _, tx in ipairs({ 25, 33 }) do
  O.dots(c, { { tx, 40 }, { tx + 1, 40 }, { tx + 2, 40 }, { tx + 3, 40 } }, GOLD[2])
  O.dots(c, { { tx, 41 }, { tx + 2, 41 } }, IRON[1])
  O.dot(c, tx + 1, 40, GOLD[3])
end

O.shift(c, 4, 0)
O.done(c, "gatepost-hoot-yard")
