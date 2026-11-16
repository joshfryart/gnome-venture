-- Net Nudge (ow-net-nudge), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c02/opus3), built on opus2.
-- Wayfinder, common, Olivewhistle. "Mends one net a day and nudges the fish towards the quay."
-- A round sea-teal pal wearing its fishing net as a hood: the net is gathered on top into a round cork float
-- (round knob), drapes over the crown in a rope-tan diamond mesh and ends in a hem of red floats, so the face
-- below sits on clean teal skin. A wooden netting needle is tucked into the mesh (it is mid-mend).
-- Richness (opus3): twisted rope strands (alternate tones) with lit knots, the mesh casts a 1 px shadow on the
-- skin lower-right (reads as a net sitting ON the head, not printed), soft scale arcs on the lower body (kept off
-- the face), banded cork floats with a lit cap, seawater drops beading off the hem, fish scales + striped fins,
-- woodgrain on the needle, a wake ripple behind the fish.
-- quirk: a little red fish being nudged along by its flipper, nose pointing the way to the quay.
-- closer look: today's mend. One mesh cell on the crown is new bright cord tied with a red thread that runs back
-- to the needle's eye.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-net-nudge-yard", 64)

local SEA  = { "#1d3f55", "#245e74", "#2f8592", "#48aaa6", "#7ccbb8", "#b9e8d4" }
local ROPE = { "#5a3a2c", "#7e5636", "#a87d4c", "#cba468", "#e6c88c", "#f4e2b0" }
local CORK = { "#6a2430", "#a3343a", "#d4553f", "#ef8a5a", "#f8bf8a" }
local FISH = { "#7a2c34", "#b8433a", "#e3703f", "#f6a456", "#fbd58a" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local NEWC = { "#8a6a3c", "#b8925a", "#dcb878", "#f0d9a0", "#f8ecc4", "#f8ecc4" } -- today's fresh cord
local RED  = "#c8333f"

c:groundShadow(34, 56, 22, 2.5)

-- body: round
local body = c:ellipse(37, 37, 16, 16)
local bb = {}
body:each(function(x, y) if y > 51 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, SEA, { sphere = { 32, 31, 19 }, bias = bb, amb = .2, wrap = .35, rim = true, bounce = "#5b6a9a", bmax = 2 })

local function hem(x) return 29 + ((x - 37) / 16) ^ 2 * 8 end
local function isNet(x, y) return y < hem(x) and ((x + y) % 6 == 0 or (x - y) % 6 == 0) end
local function face(x, y) return x >= 24 and x <= 50 and y >= 32 and y <= 47 end
local function mend(x, y) return x >= 40 and x <= 46 and y >= 20 and y <= 26 end -- the freshly mended cell

-- skin: sparse pebbled freckles on the lower body, off the face (1 down, a few 1 up on the lit side)
O.tex(c, bI, bT, SEA, function(x, y, i)
  if isNet(x, y) or face(x, y) or y < hem(x) + 2 then return end
  local h = H(x, y, 31)
  if h > .9 and i >= 2 and i <= 5 then return -1 end
  if h < .05 and i >= 3 and i <= 4 then return 1 end
end)
-- the mesh shadow: skin just lower-right of a strand drops one tone
O.tex(c, bI, bT, SEA, function(x, y, i)
  if isNet(x, y) or y >= hem(x) + 1 then return end
  if isNet(x, y - 1) then return -1 end
end)
-- net hood: rope mesh, today's mended cell in fresh cord
O.retone(c, bI, bT, { ROPE[2], ROPE[3], ROPE[4], ROPE[5], ROPE[6], ROPE[6] }, function(x, y) return isNet(x, y) and not mend(x, y) end)
O.retone(c, bI, bT, NEWC, function(x, y) return isNet(x, y) and mend(x, y) end)
-- rope twist: every other pixel along a strand one tone down; knots one tone up
O.tex(c, bI, bT, ROPE, function(x, y, i)
  if not isNet(x, y) or mend(x, y) then return end
  if (x + y) % 6 == 0 and (x - y) % 6 == 0 then return 1 end
  if i >= 5 and (x + 2 * y) % 4 == 0 then return -1 end -- twist only shows on the lit strands
end)
-- hem cord
local hm = HP.mask()
for x = 21, 53 do
  local y = math.floor(hem(x) + .5)
  if body:has(x, y) then hm:set(x, y) end
end
local hI, hT = O.shade(c, hm, ROPE, { R = 1, amb = .4 })
O.tex(c, hI, hT, ROPE, function(x, y, i) if x % 3 == 0 then return -1 end end)
-- banded floats on the hem
for _, fx in ipairs({ 25, 37, 49 }) do
  local fy = math.floor(hem(fx) + .5)
  local fm = c:rect(fx - 2, fy, fx + 2, fy + 2) fm:cut(c:rect(fx - 2, fy, fx - 2, fy)) fm:cut(c:rect(fx + 2, fy + 2, fx + 2, fy + 2))
  O.shade(c, fm, CORK, { R = 1, amb = .35, cuts = { .25, .45, .65, .84 } })
  O.dots(c, { { fx - 1, fy + 1 }, { fx, fy + 1 }, { fx + 1, fy + 1 } }, "#e8d6b0") -- cream band
  O.dot(c, fx + 1, fy + 1, "#b8a488")
  O.dot(c, fx - 1, fy, CORK[5])
end
-- round knob: the net gathered into a cork float on top
local tie = c:rect(36, 18, 38, 21)
local tI, tT = O.shade(c, tie, ROPE, { R = 1, amb = .3 })
O.tex(c, tI, tT, ROPE, function(x, y, i) if (x + y) % 2 == 0 then return -1 end end) -- whipping turns
local fI, fT = O.shade(c, c:ellipse(37, 15, 4, 3.5), CORK, { sphere = { 36, 13, 5 }, amb = .25, sep = CORK[1], cuts = { .25, .45, .65, .84 }, rim = true })
O.tex(c, fI, fT, CORK, function(x, y, i) if y == 15 then return -1 end if H(x, y, 11) > .86 and i >= 2 then return -1 end end) -- cork pits + band
O.dots(c, { { 35, 13 }, { 36, 13 } }, CORK[5])

-- netting needle tucked into the mesh (upper right), with grain; the mend thread runs from its eye
local nI, nT = O.shade(c, c:line({ { 45, 19 }, { 52, 26 } }, 2), WOOD, { R = 1, amb = .3, sep = WOOD[1] })
O.tex(c, nI, nT, WOOD, function(x, y, i) if (x - y) % 3 == 0 and i >= 2 then return -1 end end)
O.dots(c, { { 47, 21 }, { 48, 22 } }, WOOD[1]) -- the needle's slot
O.dot(c, 45, 19, WOOD[4])
-- the red mend thread: from the needle eye down to a knot tied on the new cell
O.dots(c, { { 46, 22 }, { 45, 23 }, { 44, 24 } }, RED)
O.dots(c, { { 43, 23 }, { 43, 24 } }, RED) O.dot(c, 42, 24, "#f07a6a") -- the knot, lit

-- face on clean skin
c:eyeLocked(28, 35)
c:eyeLocked(41, 35)
O.dots(c, { { 26, 42 }, { 27, 42 } }, "#f5809f") O.dots(c, { { 46, 42 }, { 47, 42 } }, "#f5809f")
O.dots(c, { { 34, 43 }, { 35, 44 }, { 36, 44 }, { 37, 44 }, { 38, 44 }, { 39, 43 } }, P.ink)
O.dots(c, { { 36, 45 }, { 37, 45 } }, "#d4553f") -- tongue

-- right flipper resting, left flipper reaching to nudge the fish (with webbing ridges)
O.shade(c, c:ellipse(54, 44, 2.5, 4), SEA, { R = 1, amb = .3, sep = SEA[1], rim = true })
local fl = c:poly{ { 23, 41 }, { 20, 44 }, { 19, 47 }, { 21, 49 }, { 24, 47 } }
local lI, lT = O.shade(c, fl, SEA, { R = 2, amb = .3, sep = SEA[1], rim = true })
O.tex(c, lI, lT, SEA, function(x, y, i) if (x + y) % 3 == 0 and y > 44 and i >= 3 then return -1 end end)

-- quirk: the fish being nudged, nose to the left (the quay); the flipper tip touches its tail
local fish = c:ellipse(9, 51, 5, 3)
local fb = {}
fish:each(function(x, y) if y >= 53 then fb[K(x, y)] = 1 end end) -- pale belly
local sI, sT = O.shade(c, fish, FISH, { R = 2, bias = fb, amb = .3, cuts = { .25, .45, .65, .84 }, rim = true, bounce = "#c76a7a", bmax = 2 })
O.tex(c, sI, sT, FISH, function(x, y, i) if x >= 8 and y <= 52 and (x + y) % 2 == 0 and y % 2 == 0 and i >= 2 then return -1 end end) -- scales
local tail = c:poly{ { 13, 51 }, { 17, 47 }, { 18, 48 }, { 16, 51 }, { 18, 54 }, { 17, 55 } }
local aI, aT = O.shade(c, tail, FISH, { R = 1, amb = .3, sep = FISH[1], cuts = { .25, .45, .65, .84 } })
O.tex(c, aI, aT, FISH, function(x, y, i) if x >= 15 and (y % 2 == 0) then return -1 end end) -- fin rays
O.shade(c, c:poly{ { 7, 48 }, { 10, 46 }, { 11, 48 } }, FISH, { R = 1, amb = .3, cuts = { .25, .45, .65, .84 } }) -- dorsal fin
O.dot(c, 9, 47, FISH[2])
O.dots(c, { { 6, 50 }, { 6, 49 } }, P.ink) O.dot(c, 5, 49, "#fbd58a")
O.dots(c, { { 9, 50 }, { 9, 51 }, { 9, 52 } }, FISH[2]) -- gill line
O.dots(c, { { 4, 52 } }, FISH[1]) -- mouth

O.done(c, "ow-net-nudge-yard")
