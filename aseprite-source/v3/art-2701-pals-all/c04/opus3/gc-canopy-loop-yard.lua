-- Canopy Loop (gc-canopy-loop), yard sprite 64x64. Opus richness pass (c04/opus3), built on c04/opus2.
-- Richness pass: the clump is now layered overlapping leaves (each with a lit upper lip and a dark lower edge) plus
-- rim midribs, hue-shifted greens going teal in shade, a twisted rope with fibre stripes, plank grain and nail heads,
-- vine bark ticks, a bigger open vine loop with the rope running through its hole and a curling tendril tail,
-- two small leaves on the vine, a dew drop on the hibiscus. Closer look: the parrot raises a blue wing to wave back,
-- and one rim leaf has a little bite taken out of it.
-- Bloomcaller, uncommon, Great Canopy. "Swings from bridge to bridge and says good morning to every parrot."
-- A round, scalloped bundle of canopy leaves hanging from a rope bridge by its own vine, which it has tied into a
-- loop over the rope; a pink hibiscus behind one ear (bloomcaller), a leaf-hand raised in a wave, swing arcs.
-- Fixed from Haiku: a plain green ball with a ring beside it gave no clue to "loop" or "swings"; now the loop
-- is the vine hooked over the bridge rope, the leafy rim says canopy, and the wave says good morning.
-- quirk: a small red parrot perched on the bridge plank, being greeted.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("gc-canopy-loop-yard", 64)

local LEAF  = { "#143834", "#1c5640", "#2c7842", "#4c9c46", "#84c45a", "#c2e48c" }
local VINE  = { "#3a2a1e", "#5e4a2a", "#86703a", "#a89a52" }
local ROPE  = { "#6a4a2a", "#a8804e", "#d4b47a" }
local WOOD  = { "#3e2a22", "#6a4630", "#94683e", "#b88c56" }
local BIRD  = { "#5a1424", "#a82632", "#d8402e", "#f0703e" }
local FLOW  = { "#7a1e4a", "#c83a6a", "#f0709a", "#fbb0c4" }

-- bridge: rope with a plank at the left end
local rope, rn = O.tube({ { 4, 8 }, { 20, 11 }, { 44, 11 }, { 59, 8 } }, function() return 1 end)
local rI, rT = O.shadeN(c, rope, rn, ROPE, { amb = .4, wrap = .5, cuts = { .45, .8 } })
O.tex(c, rI, rT, ROPE, function(x, y, i) if (x + y) % 3 == 0 then return -1 end end) -- twisted fibre stripes
local plank = c:rect(3, 11, 17, 13)
local pI, pT = O.shade(c, plank, WOOD, { R = 1, amb = .3, wrap = .4, sep = WOOD[1] })
O.mark(c, { { 6, 12 }, { 7, 12 }, { 8, 12 }, { 12, 12 }, { 13, 12 }, { 14, 12 } }, WOOD[2]) -- grain
O.mark(c, { { 4, 12 }, { 16, 12 } }, "#c8c8d0") -- nail heads

-- quirk: little parrot on the plank
local bird = c:ellipse(10.5, 7.5, 2.6, 3.4)
bird:add(c:ellipse(10.5, 3.5, 2.2, 2.2))
O.shade(c, bird, BIRD, { R = 2, amb = .3, wrap = .4, cuts = { .3, .55, .8 } })
O.flat(c, c:rect(13, 3, 13, 4), "#f5dc9a", "beak") O.dot(c, 14, 4, "#e8bc66")
-- closer look: the parrot raises its blue wing to wave back
local wing = c:poly{ { 8, 7 }, { 6, 2 }, { 5, 1 }, { 4, 3 }, { 7, 8 } }
O.flat(c, wing, "#2f63a8", "wing") O.dots(c, { { 6, 3 }, { 5, 2 } }, "#7cbde8") O.dot(c, 4, 3, "#f0be38")
O.dots(c, { { 7, 10 }, { 6, 11 } }, "#f0be38") -- tail
O.dot(c, 11, 3, P.ink)

-- vine up from the head, looped over the rope
local vine, vn = O.tube({ { 31, 26 }, { 30, 21 }, { 32, 17 }, { 33, 15 } }, function() return 1.2 end)
local vI, vT = O.shadeN(c, vine, vn, VINE, { amb = .3, wrap = .4, cuts = { .35, .6, .85 }, sep = VINE[1] })
-- an open loop of vine round the rope: the rope runs through its hole
local loop = c:ellipse(36, 10, 4.6, 5.6) loop:cut(c:ellipse(36, 10, 2.2, 3.2))
local lI, lT = O.shade(c, loop, VINE, { R = 1, amb = .35, wrap = .4, cuts = { .35, .6, .85 }, sep = VINE[1] })
O.tex(c, lI, lT, VINE, function(x, y, i) if (x * 2 + y) % 5 == 0 and i >= 3 then return -1 end end) -- bark ticks
-- the rope passes through: drawn over the loop's back half only (left side stays in front)
rope:each(function(x, y) if x >= 34 and x <= 41 then c:put(x, y, ((x + y) % 3 == 0) and ROPE[1] or ROPE[2], rT) end end)
loop:each(function(x, y) if x <= 33 and rope:has(x, y) then c:put(x, y, VINE[3], lT) end end)
-- curling tendril tail off the loop's right side
for _, p in ipairs({ { 41, 13 }, { 42, 14 }, { 43, 15 }, { 44, 15 }, { 45, 14 }, { 45, 13 }, { 44, 12 } }) do O.dot(c, p[1], p[2], VINE[3]) end
-- two small leaves on the vine
O.shade(c, c:ellipse(28.5, 21, 2, 1.2), LEAF, { R = 1, amb = .35, wrap = .4, sep = LEAF[1] })
O.shade(c, c:ellipse(35.5, 18, 2, 1.2), LEAF, { R = 1, amb = .35, wrap = .4, sep = LEAF[1] })

-- leafy body: scalloped clump
local CX, CY = 31, 40
local circ = { { CX, CY, 13.5, 13 } }
for k = 0, 11 do
  local a = k / 12 * 2 * math.pi + .2
  circ[#circ + 1] = { CX + math.cos(a) * 13, CY + math.sin(a) * 12.5, 3.2, 3.2 }
end
local body = O.unionCircles(circ)
local bI, bT = O.shade(c, body, LEAF, { sphere = { 26, 33, 20 }, amb = .15, wrap = .4, rim = true, bounce = "#3a7a8a", bmax = 2, sep = LEAF[1] })
-- leaf veins: a short midrib in each rim scallop, pointing outward
for k = 0, 11 do
  local a = k / 12 * 2 * math.pi + .2
  for r = 10, 13 do
    local x, y = math.floor(CX + math.cos(a) * r + .5), math.floor(CY + math.sin(a) * r * .96 + .5)
    local i = bI[K(x, y)]
    if i then O.mark(c, { { x, y } }, LEAF[math.max(1, i - 1)]) end
  end
end
-- layered overlapping leaves: each tile has a lit upper lip and a dark lower edge (off the face)
O.tex(c, bI, bT, LEAF, function(x, y, i)
  if y >= 34 and y <= 47 and x >= 22 and x <= 43 then return 0 end
  local row = y // 4
  local u = (x + (row % 2) * 3) % 6
  local v = y % 4
  if v == 3 and u >= 1 and u <= 4 and i >= 2 then return -1 end
  if v == 0 and (u == 1 or u == 2) and i >= 3 then return 1 end
end)
-- closer look: a bite out of one rim leaf (lower left)
c.pix[50 * 64 + 21] = nil c.own[50 * 64 + 21] = nil c.pix[50 * 64 + 22] = nil c.own[50 * 64 + 22] = nil c.pix[49 * 64 + 21] = nil c.own[49 * 64 + 21] = nil

-- waving leaf-hand
local arm, an = O.tube({ { 43, 40 }, { 48, 38 }, { 51, 33 }, { 52, 28 } }, function() return 1.3 end)
O.shadeN(c, arm, an, VINE, { amb = .3, wrap = .4, cuts = { .35, .6, .85 }, sep = VINE[1] })
local hand = O.unionCircles{ { 52.5, 26, 2.8, 3.2 } }
hand:add(c:poly{ { 50, 25 }, { 55, 25 }, { 52.5, 19 } })
O.shade(c, hand, LEAF, { R = 2, amb = .3, wrap = .4, sep = LEAF[1] })
O.mark(c, { { 52, 21 }, { 52, 22 }, { 52, 23 }, { 52, 24 }, { 52, 25 } }, LEAF[3])

-- hibiscus behind its ear
local pet = O.unionCircles{ { 18, 28, 2.5, 2.5 }, { 22, 27, 2.5, 2.5 }, { 23, 31, 2.5, 2.5 }, { 19.5, 33, 2.5, 2.5 }, { 16.5, 31.5, 2.5, 2.5 } }
O.shade(c, pet, FLOW, { sphere = { 18, 28, 7 }, amb = .35, wrap = .4, sep = FLOW[1], cuts = { .3, .55, .8 } })
O.flat(c, c:rect(19, 30, 20, 31), "#f0be38", "pistil") O.dot(c, 21, 29, "#fbe07a") O.dot(c, 22, 28, "#fbe07a")
O.mark(c, { { 17, 27 } }, "#c6eedc") O.mark(c, { { 17, 28 } }, "#4cb0b2") -- dew drop

-- face
c:eyeLocked(25, 37)
c:eyeLocked(35, 37)
c:cheek(22, 43) c:cheek(41, 43)
O.dots(c, { { 29, 43 }, { 30, 44 }, { 31, 44 }, { 32, 44 }, { 33, 44 }, { 34, 43 } }, P.ink)
O.dots(c, { { 31, 45 }, { 32, 45 } }, "#c8404a")

O.shift(c, 0, 3)
O.done(c, "gc-canopy-loop-yard", function(c)
  -- swing arcs on the left (not outlined)
  for _, p in ipairs({ { 12, 34 }, { 11, 35 }, { 11, 36 }, { 11, 37 }, { 11, 38 }, { 11, 39 }, { 12, 40 }, { 8, 36 }, { 7, 37 }, { 7, 38 }, { 8, 39 } }) do c:put(p[1], p[2], "#d0e2b0") end
end)
