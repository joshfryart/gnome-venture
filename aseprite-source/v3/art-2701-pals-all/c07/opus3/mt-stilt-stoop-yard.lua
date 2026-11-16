-- Stilt Stoop (mt-stilt-stoop), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c07/opus3), built on opus2.
-- opus3: peach-fuzz freckles on the body, frayed straw tips on the brim and a red hat band, two-board plank with end
-- grain and pegs, lit vertical streaks on the bamboo plus a leaf from a node, stilt reflections and ripple rings in the
-- canal; closer look: a clay pot with a seedling on the stoop (seedkeeper) and an orange minnow under the water.
-- Monsoontangle, common, seedkeeper. "Lives up on stilts and waves at the canal every morning."
-- A round amber body standing on two jointed bamboo stilts, like a little stilt house: a woven straw cone hat for
-- a roof, a plank stoop (porch board) under its belly, stilts planted in a strip of canal water with ripples.
-- Haiku fixes: stilts are 3 px bamboo with nodes (they held up badly at 36 px), the moss cap became a woven cone
-- roof-hat, the porch plank makes "stoop" readable, the waving arm is a clear mitten with motion ticks.
-- quirk: waving one mitten high at the canal (two motion ticks beside it).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mt-stilt-stoop-yard", 64)

local AMB  = { "#6a3020", "#9a4a24", "#c86e2a", "#e8963a", "#f8bc5c", "#ffdc96" }
local BAM  = { "#3a4a24", "#55692c", "#7a8c36", "#a2ac48", "#c8c870", "#e8e4a0" }
local STR  = { "#6a4422", "#8e6230", "#b88a44", "#d8b060", "#ecd088", "#faecb4" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

-- canal water strip (flat, pale ripple lines), stilts stand in it
local water = c:ellipse(32, 57, 19, 2.6)
O.flat(c, water, SEA[3], "water")
water:each(function(x, y) if y >= 58 then c:put(x, y, SEA[2], { r = { name = "water" } }) end end)

-- bamboo stilts with nodes
for _, s in ipairs({ { 27, 23 }, { 37, 41 } }) do
  local m, n, T = O.tube({ { s[1], 34 }, { s[1] + (s[2] - s[1]) * .33, 41 }, { s[1] + (s[2] - s[1]) * .66, 48 }, { s[2], 57 } }, function() return 1.5 end)
  local bias = {}
  m:each(function(x, y) if y % 7 == 0 then bias[K(x, y)] = -2 elseif y % 7 == 1 then bias[K(x, y)] = 1 end end)
  local bi, bt = O.shadeN(c, m, n, BAM, { amb = .3, wrap = .45, bias = bias, sep = BAM[1], rim = true })
  O.tex(c, bi, bt, BAM, function(x, y, i) if y % 7 > 2 and H(x, y // 3, 2) > .8 and i >= 3 and i <= 5 then return 1 end end)
end
-- a bamboo leaf sprouting from a node on the left stilt
O.shade(c, c:poly{ { 25, 42 }, { 20, 40 }, { 17, 41 }, { 21, 43 } }, BAM, { R = 1, amb = .4, cuts = O.CUTS, sep = BAM[1] })
O.dots(c, { { 19, 41 }, { 20, 41 }, { 21, 42 } }, BAM[3])
-- front water lip over the stilt feet + ripple rings
O.dots(c, { { 21, 57 }, { 22, 57 }, { 23, 57 }, { 24, 57 }, { 25, 57 }, { 39, 57 }, { 40, 57 }, { 41, 57 }, { 42, 57 }, { 43, 57 } }, SEA[3])
O.dots(c, { { 19, 56 }, { 20, 56 }, { 27, 56 }, { 28, 56 }, { 37, 56 }, { 38, 56 }, { 45, 56 }, { 46, 56 } }, SEA[4])
O.dots(c, { { 14, 57 }, { 15, 57 }, { 49, 57 }, { 50, 57 }, { 31, 58 }, { 32, 58 }, { 33, 58 } }, SEA[4])
O.dots(c, { { 23, 58 }, { 23, 59 }, { 41, 58 }, { 41, 59 } }, "#55692c") -- stilt reflections
-- closer look: an orange minnow under the water
O.dots(c, { { 33, 57 }, { 34, 57 }, { 35, 57 } }, "#f08a3a") O.dot(c, 36, 57, "#c8562a") O.dot(c, 33, 57, "#ffc078")

-- resting arm (left) behind the body
O.shade(c, c:ellipse(19, 31, 3, 2.5), AMB, { R = 1, amb = .3, sep = AMB[1] })
-- waving arm (right): up and out, mitten hand
local arm, an = O.tube({ { 41, 27 }, { 46, 24 }, { 49, 19 }, { 51, 14 } }, function(t) return 2 end)
O.shadeN(c, arm, an, AMB, { amb = .3, wrap = .45, sep = AMB[1], rim = true })
local hand = c:ellipse(52, 12, 3, 3)
hand:add(c:rect(50, 7, 50, 10)) hand:add(c:rect(52, 6, 52, 10)) hand:add(c:rect(54, 7, 54, 10)) -- fingers
hand:add(c:rect(48, 11, 49, 12)) -- thumb
O.shade(c, hand, AMB, { sphere = { 50, 9, 6 }, amb = .32, sep = AMB[1], rim = true })

-- round body
local body = c:ellipse(31, 27, 12.5, 10.5)
local bI, bT = O.shade(c, body, AMB, { sphere = { 26, 22, 17 }, amb = .3, wrap = .45, sep = AMB[1], rim = true, bounce = "#7a5a8a", bmax = 2 })
O.tex(c, bI, bT, AMB, function(x, y, i)
  local face = x >= 22 and x <= 40 and y >= 21 and y <= 33
  if not face and H(x, y, 5) > .9 and i >= 3 then return -1 end           -- peach-fuzz freckles
  if not face and H(x + 1, y, 5) > .9 and i >= 2 and i <= 4 then return 1 end
end)

-- plank stoop under the belly, ends sticking out
local plank = c:rect(9, 36, 45, 38)
O.shade(c, plank, WOOD, { R = 1, amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = WOOD[1], rim = true })
O.dots(c, { { 20, 36 }, { 21, 36 }, { 22, 36 }, { 30, 36 }, { 31, 36 }, { 41, 36 }, { 42, 36 } }, WOOD[2]) -- grain
for x = 10, 44 do O.dot(c, x, 37, (x % 9 == 0) and WOOD[3] or WOOD[1]) end -- seam between the two boards
O.dots(c, { { 26, 38 }, { 27, 38 }, { 35, 38 }, { 36, 38 }, { 37, 38 } }, WOOD[2])
O.dots(c, { { 9, 36 }, { 9, 38 } }, WOOD[4]) O.dots(c, { { 45, 36 }, { 45, 38 } }, WOOD[2]) -- end grain
O.dots(c, { { 25, 36 }, { 36, 36 }, { 25, 38 }, { 36, 38 } }, "#d8b060") -- pegs
-- closer look: a clay pot with a seedling on the stoop end
local pot = c:poly{ { 10, 31 }, { 15, 31 }, { 14, 35 }, { 11, 35 } }
O.shade(c, pot, { "#6a2a24", "#9a4630", "#c86a3e", "#e8925a", "#ffbe8a" }, { R = 1, amb = .35, cuts = { .25, .45, .65, .85 }, sep = "#6a2a24" })
O.flat(c, c:rect(10, 31, 15, 31), "#e8925a", "potrim") O.dot(c, 10, 31, "#ffbe8a")
O.dots(c, { { 12, 30 }, { 12, 29 }, { 13, 28 } }, "#3f7a3a") O.dots(c, { { 11, 28 }, { 10, 27 }, { 14, 27 }, { 15, 26 } }, "#8cc44a")

-- woven straw cone hat
local hat = c:poly{ { 31, 4 }, { 32, 4 }, { 49, 17 }, { 46, 19 }, { 17, 19 }, { 14, 17 } }
for _, fx in ipairs({ 15, 19, 24, 39, 44, 48 }) do hat:add(c:rect(fx, 19, fx, 20)) end -- frayed straw ends
local hb = {}
hat:each(function(x, y) if (y % 3 == 0) then hb[K(x, y)] = -1 end if (y % 3 == 1) and ((x + y) % 4 == 0) then hb[K(x, y)] = 1 end end)
O.shade(c, hat, STR, { R = 3, amb = .3, wrap = .45, bias = hb, sep = STR[1], rim = true, bounce = "#8a6a8a", bmax = 2 })
O.flat(c, c:rect(17, 18, 46, 19), STR[2], "brimshade") O.dots(c, { { 18, 18 }, { 19, 18 }, { 20, 18 } }, STR[4])
O.dots(c, { { 31, 4 }, { 32, 4 }, { 31, 5 } }, STR[6]) -- tip glint
-- red hat band with a knot
for x = 22, 41 do local y = 15 if x < 24 or x > 39 then y = 16 end O.dot(c, x, y, (x % 4 == 0) and "#e8493b" or "#b52e3f") end
O.dots(c, { { 40, 15 }, { 41, 15 }, { 42, 16 } }, "#7a2238")
-- chin strap
O.dots(c, { { 19, 20 }, { 19, 21 }, { 20, 22 } }, "#b52e3f") O.dots(c, { { 43, 20 }, { 43, 21 }, { 42, 22 } }, "#b52e3f")

-- face
c:eyeLocked(24, 23)
c:eyeLocked(34, 23)
c:cheek(21, 29) c:cheek(40, 29)
-- open happy mouth
O.dots(c, { { 28, 30 }, { 29, 30 }, { 30, 30 }, { 31, 30 }, { 32, 30 }, { 33, 30 }, { 34, 30 }, { 29, 31 }, { 33, 31 }, { 30, 32 }, { 31, 32 }, { 32, 32 } }, "#3e1620")
O.dots(c, { { 30, 31 }, { 31, 31 }, { 32, 31 } }, "#e8493b")

O.shift(c, -4, 0)
O.done(c, "mt-stilt-stoop-yard", function(c)
  for _, p in ipairs({ { 53, 7 }, { 54, 8 }, { 54, 12 }, { 55, 13 }, { 42, 5 }, { 41, 4 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#fff4d6", { r = { name = "tick" } }) end
  end
end)
