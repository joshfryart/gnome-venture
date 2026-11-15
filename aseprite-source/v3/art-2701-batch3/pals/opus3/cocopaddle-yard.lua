-- Cocopaddle (ss-cocopaddle), yard sprite 64x64. Opus richness pass (art-2701-batch3/pals/opus3), built on opus2.
-- Fix vs opus2: the swell is now two planes of real water: a back swell wider than the hull with a rolling
-- crest line, and a front wave that laps over the hull's bottom and swallows the paddle blade, with foam caps,
-- wave-line texture and a wake. Richness: hairy coir strokes on the husk, rim light + cool bounce on the hull,
-- driftwood grain on the mast, leaflet edges on the frond sail.
-- Thornblade, rare, Sunsprinkle. "Sails a coconut half across the whole archipelago."
-- The pal is a half coconut boat: hairy fibre husk hull with the face on it (one of the coconut's
-- three dark pores is its nose), a cream flesh rim, a driftwood mast with a palm-frond sail, and a
-- stubby arm gripping a paddle whose blade ends in a thorn point. Riding a small sea swell.
-- quirk: a message in a bottle bobbing alongside; look closer and the rolled note is tied with a red ribbon.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("cocopaddle-yard", 64)

local HUSK = { "#3a2220", "#5e3628", "#865234", "#a8703f", "#c99254", "#e3b676" }
local MEAT = { "#c9b08e", "#e6d4b2", "#f6ead0", "#fff4d6" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local LEAF = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }
local SEA  = { "#24406e", "#2f6a9e", "#3a8fb8", "#5fc4c8", "#9ee4dc", "#d4f6ee" }
local GLAS = { "#3f9150", "#7cc35a", "#b6e0a0" }

-- back swell: wider than the hull, rolling crest
local back = HP.mask()
for x = 2, 61 do
  local top = math.floor(48.5 + 1.6 * math.sin(x * .32 + .8) + .5)
  for y = top, 56 do back:set(x, y) end
end
back:cut(c:ellipse(1, 56, 3, 2)) back:cut(c:ellipse(62, 56, 3, 2))
local bkb = {}
back:each(function(x, y) bkb[K(x, y)] = -1 end)
local sI, sT = O.shade(c, back, SEA, { R = 2, bias = bkb, amb = .35, wrap = .4, rim = true })
O.tex(c, sI, sT, SEA, function(x, y, i) -- wave lines
  if (y == 52 and x % 7 < 3) or (y == 54 and (x + 4) % 9 < 3) then return -1 end
end)
for x = 2, 61 do -- foam crest
  local top = math.floor(48.5 + 1.6 * math.sin(x * .32 + .8) + .5)
  if c:get(x, top) and (math.sin(x * .32 + .8) > .2) then O.mark(c, { { x, top } }, SEA[6]) end
end

-- mast
O.shade(c, c:rect(31, 6, 32, 38), WOOD, { R = 1, amb = .3, rim = true })
O.dots(c, { { 32, 10 }, { 32, 11 }, { 31, 18 }, { 31, 19 }, { 32, 26 }, { 32, 27 }, { 31, 34 } }, WOOD[2]) -- grain
O.dots(c, { { 31, 14 }, { 32, 22 }, { 31, 30 } }, WOOD[2]) -- driftwood knots
-- palm-frond sail, bellied to the right
local sail = c:poly{ { 33, 6 }, { 42, 9 }, { 49, 15 }, { 53, 24 }, { 52, 31 }, { 46, 33 }, { 33, 33 } }
local lb = {}
sail:each(function(x, y)
  -- leaflet splits: diagonal grooves running down-right from the midrib
  if (y - x * .55) % 4 < 1 and x > 35 then lb[K(x, y)] = -2 end
  if math.abs((y - 6) - (x - 33) * 1.25) < .7 then lb[K(x, y)] = 2 end -- midrib
end)
local lI, lT = O.shade(c, sail, LEAF, { R = 4, bias = lb, amb = .2, wrap = .35, sep = LEAF[1], rim = true })
O.tex(c, lI, lT, LEAF, function(x, y, i) if (y - x * .55) % 4 >= 1 and (y - x * .55) % 4 < 1.6 and x > 35 and i <= 4 then return 1 end end) -- lit leaflet edges
-- ragged leaf tips on the trailing edge
for _, p in ipairs({ { 54, 26 }, { 53, 31 }, { 50, 19 }, { 47, 34 } }) do O.dot(c, p[1], p[2], LEAF[3]) end

-- hull: half coconut bowl
local hull = c:ellipse(31, 37, 21, 16)
hull:cut(c:rect(0, 0, 63, 36))
local hb = {}
hull:each(function(x, y) -- coir fibre strokes
  local h = (x * 13 + y * 7) % 10
  if h == 0 then hb[K(x, y)] = -1 elseif h == 5 and y < 50 then hb[K(x, y)] = 1 end
end)
local hI, hT = O.shade(c, hull, HUSK, { sphere = { 24, 38, 24 }, bias = hb, amb = .2, wrap = .35, bounce = "#5c5a78", bmax = 2 })
-- hairy coir: short diagonal fibre strokes
O.tex(c, hI, hT, HUSK, function(x, y, i)
  local u = (x * 2 + y) % 6
  if u == 0 and H(x, y, 8) > .35 and i >= 2 then return -1 end
  if u == 3 and H(x, y, 9) > .6 and i <= 5 then return 1 end
end)
-- frayed fibre tufts sticking out of the hull silhouette
O.dots(c, { { 9, 41 }, { 53, 42 }, { 52, 46 }, { 10, 45 } }, HUSK[3])
-- cream flesh rim and the dark hollow inside
local rimO = c:ellipse(31, 37, 21, 3.5)
local hollow = c:ellipse(31, 36.5, 18, 2)
rimO:cut(c:rect(0, 0, 63, 34))
O.shade(c, rimO, MEAT, { R = 1, amb = .45, cuts = { .3, .6, .85 } })
O.flat(c, hollow, HUSK[2], "hollow")
O.dots(c, { { 15, 36 }, { 16, 36 }, { 17, 35 } }, HUSK[1])
O.shade(c, c:rect(31, 34, 32, 37), WOOD, { R = 1, amb = .3 }) -- mast foot in the hollow

-- paddle in front of the hull, blade dipped in the swell, thorn point at the tip
local sh, shn = O.tube({ { 19, 27 }, { 16, 35 }, { 13, 43 }, { 10, 50 } }, function(t) return 1 end)
O.shadeN(c, sh, shn, WOOD, { amb = .35, sep = WOOD[1] })
O.dots(c, { { 19, 26 }, { 20, 25 } }, WOOD[3]) -- grip knob
local blade = c:poly{ { 7, 48 }, { 12, 49 }, { 11, 55 }, { 8, 59 }, { 6, 54 } }
O.shade(c, blade, WOOD, { R = 1, amb = .3, sep = WOOD[1] })
O.dot(c, 7, 50, WOOD[4])
-- arm from the rim gripping the shaft
local arm, an = O.tube({ { 20, 39 }, { 18, 37 }, { 17, 35 }, { 16, 33 } }, function(t) return 1.5 end)
O.shadeN(c, arm, an, HUSK, { amb = .3, sep = HUSK[1] })
O.dots(c, { { 15, 32 }, { 16, 31 }, { 17, 32 } }, HUSK[5])

-- face on the hull
c:eyeLocked(22, 41)
c:eyeLocked(35, 41)
c:cheek(19, 47) c:cheek(42, 47)
-- nose: one of the coconut's dark pores, with a cream glint
O.dots(c, { { 30, 46 }, { 31, 46 }, { 30, 47 }, { 31, 47 } }, HUSK[1]) O.dot(c, 30, 46, MEAT[2])
-- brave grin
O.dots(c, { { 27, 49 }, { 28, 50 }, { 29, 50 }, { 30, 50 }, { 31, 50 }, { 32, 50 }, { 33, 50 }, { 34, 49 } }, P.ink)

-- front wave: laps over the hull's bottom and the paddle blade, foam caps, a wake curling off the stern
local front = HP.mask()
for x = 3, 60 do
  local top = math.floor(53.5 + 1.3 * math.sin(x * .4 + 2.2) + .5)
  for y = top, 58 do front:set(x, y) end
end
front:cut(c:ellipse(2, 58, 3, 2)) front:cut(c:ellipse(61, 58, 3, 2))
local fI, fT = O.shade(c, front, SEA, { R = 2, amb = .4, wrap = .45, rim = true, bounce = "#3a6aa0", bmax = 2 })
O.tex(c, fI, fT, SEA, function(x, y, i) if (y == 57 and x % 6 < 2) or (y == 56 and (x + 3) % 8 == 0) then return -1 end end)
for x = 3, 60 do
  local top = math.floor(53.5 + 1.3 * math.sin(x * .4 + 2.2) + .5)
  if c:get(x, top) and math.sin(x * .4 + 2.2) > -.1 then O.mark(c, { { x, top } }, SEA[6]) end
  if c:get(x, top + 1) and math.sin(x * .4 + 2.2) > .7 then O.mark(c, { { x, top + 1 } }, SEA[5]) end
end

-- quirk: message in a bottle
local bot = c:rrect(50, 49, 57, 52, 1)
O.shade(c, bot, GLAS, { R = 1, amb = .4, cuts = { .4, .75 } })
O.flat(c, c:rect(58, 50, 59, 51), WOOD[2], "cork") O.dot(c, 58, 50, WOOD[3])
O.dots(c, { { 52, 50 }, { 53, 50 }, { 54, 50 }, { 55, 50 }, { 52, 51 }, { 53, 51 }, { 55, 51 } }, MEAT[3])
O.dots(c, { { 54, 50 }, { 54, 51 } }, "#e8493b") -- the red ribbon round the note
O.dot(c, 51, 49, SEA[6])
O.dots(c, { { 49, 53 }, { 50, 53 }, { 56, 53 }, { 57, 53 } }, SEA[6]) -- foam ring where the bottle bobs

O.done(c, "cocopaddle-yard")
