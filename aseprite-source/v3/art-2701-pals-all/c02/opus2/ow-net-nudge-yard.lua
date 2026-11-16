-- Net Nudge (ow-net-nudge), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Wayfinder, common, Olivewhistle. "Mends one net a day and nudges the fish towards the quay."
-- A round sea-teal pal wearing its fishing net as a hood: the net is gathered on top into a round cork float
-- (round knob), drapes over the crown in a rope-tan diamond mesh and ends in a hem of red floats, so the face
-- below sits on clean teal skin. A wooden netting needle is tucked into the mesh (it is mid-mend).
-- Fix vs Haiku: the lattice no longer covers the whole body (it read as a checked ball); open, wider mesh
-- with lit knots; bigger flipper doing the nudging.
-- quirk: a little red fish being nudged along by its flipper, nose pointing the way to the quay.
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

c:groundShadow(34, 56, 22, 2.5)

-- body: round
local body = c:ellipse(37, 37, 16, 16)
local bb = {}
body:each(function(x, y) if y > 51 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, SEA, { sphere = { 32, 31, 19 }, bias = bb, amb = .2, wrap = .35, rim = true, bounce = "#5b6a9a", bmax = 2 })
-- tiny scale freckles on the lower body
O.tex(c, bI, bT, SEA, function(x, y, i) if y > 44 and H(x, y, 31) > .93 and i >= 2 and i <= 5 then return 1 end end)

-- net hood: hem curve lower at the sides
local function hem(x) return 29 + ((x - 37) / 16) ^ 2 * 8 end
O.retone(c, bI, bT, { ROPE[2], ROPE[3], ROPE[4], ROPE[5], ROPE[6], ROPE[6] }, function(x, y, i)
  if y >= hem(x) then return false end
  local a, b = (x + y) % 6, (x - y) % 6
  return a == 0 or b == 0
end)
-- knots at the crossings are one tone lighter
O.tex(c, bI, bT, ROPE, function(x, y, i)
  if y < hem(x) and (x + y) % 6 == 0 and (x - y) % 6 == 0 then return 1 end
end)
-- hem cord
local hm = HP.mask()
for x = 21, 53 do
  local y = math.floor(hem(x) + .5)
  if body:has(x, y) then hm:set(x, y) end
end
O.shade(c, hm, ROPE, { R = 1, amb = .4 })
-- floats on the hem
for _, fx in ipairs({ 25, 37, 49 }) do
  local fy = math.floor(hem(fx) + .5)
  local fm = c:rect(fx - 2, fy, fx + 2, fy + 2) fm:cut(c:rect(fx - 2, fy, fx - 2, fy)) fm:cut(c:rect(fx + 2, fy + 2, fx + 2, fy + 2))
  O.shade(c, fm, CORK, { R = 1, amb = .35, cuts = { .25, .45, .65, .84 } })
  O.dot(c, fx - 1, fy, CORK[5])
end

-- round knob: the net gathered into a cork float on top
local tie = c:rect(36, 18, 38, 21)
O.shade(c, tie, ROPE, { R = 1, amb = .3 })
O.shade(c, c:ellipse(37, 15, 4, 3.5), CORK, { sphere = { 36, 13, 5 }, amb = .25, sep = CORK[1], cuts = { .25, .45, .65, .84 }, rim = true })
O.dots(c, { { 35, 13 }, { 36, 13 } }, CORK[5])

-- netting needle tucked into the mesh (upper right)
O.shade(c, c:line({ { 45, 19 }, { 52, 26 } }, 2), WOOD, { R = 1, amb = .3, sep = WOOD[1] })
O.dots(c, { { 47, 21 }, { 48, 22 } }, WOOD[1]) -- the needle's slot
O.dot(c, 45, 19, WOOD[4])

-- face on clean skin
c:eyeLocked(28, 35)
c:eyeLocked(41, 35)
O.dots(c, { { 26, 42 }, { 27, 42 } }, "#f5809f") O.dots(c, { { 46, 42 }, { 47, 42 } }, "#f5809f")
O.dots(c, { { 34, 43 }, { 35, 44 }, { 36, 44 }, { 37, 44 }, { 38, 44 }, { 39, 43 } }, P.ink)
O.dots(c, { { 36, 45 }, { 37, 45 } }, "#d4553f") -- tongue

-- right flipper resting, left flipper reaching to nudge the fish
O.shade(c, c:ellipse(54, 44, 2.5, 4), SEA, { R = 1, amb = .3, sep = SEA[1] })
local fl = c:poly{ { 23, 41 }, { 20, 44 }, { 19, 47 }, { 21, 49 }, { 24, 47 } }
O.shade(c, fl, SEA, { R = 2, amb = .3, sep = SEA[1], rim = true })

-- quirk: the fish being nudged, nose to the left (the quay); the flipper tip touches its tail
local fish = c:ellipse(9, 51, 5, 3)
local fb = {}
fish:each(function(x, y) if y >= 53 then fb[K(x, y)] = 1 end end) -- pale belly
O.shade(c, fish, FISH, { R = 2, bias = fb, amb = .3, cuts = { .25, .45, .65, .84 }, rim = true })
local tail = c:poly{ { 13, 51 }, { 17, 47 }, { 18, 48 }, { 16, 51 }, { 18, 54 }, { 17, 55 } }
O.shade(c, tail, FISH, { R = 1, amb = .3, sep = FISH[1], cuts = { .25, .45, .65, .84 } })
O.shade(c, c:poly{ { 7, 48 }, { 10, 46 }, { 11, 48 } }, FISH, { R = 1, amb = .3, cuts = { .25, .45, .65, .84 } }) -- dorsal fin
O.dots(c, { { 6, 50 }, { 6, 49 } }, P.ink) O.dot(c, 5, 49, "#fbd58a")
O.dots(c, { { 9, 50 }, { 9, 51 }, { 9, 52 } }, FISH[2]) -- gill line
O.dots(c, { { 4, 52 } }, FISH[1]) -- mouth

O.done(c, "ow-net-nudge-yard")
