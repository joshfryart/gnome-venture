-- Cocopaddle (ss-cocopaddle), yard sprite 64x64. Opus second pass (art-2701-batch3/pals/opus2).
-- Thornblade, rare, Sunsprinkle. "Sails a coconut half across the whole archipelago."
-- The pal is a half coconut boat: hairy fibre husk hull with the face on it (one of the coconut's
-- three dark pores is its nose), a cream flesh rim, a driftwood mast with a palm-frond sail, and a
-- stubby arm gripping a paddle whose blade ends in a thorn point. Riding a small sea swell.
-- quirk: a message in a bottle bobbing alongside.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("cocopaddle-yard", 64)

local HUSK = { "#3a2220", "#5e3628", "#865234", "#a8703f", "#c99254", "#e3b676" }
local MEAT = { "#c9b08e", "#e6d4b2", "#f6ead0", "#fff4d6" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local LEAF = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc", "#d4f6ee" }
local GLAS = { "#3f9150", "#7cc35a", "#b6e0a0" }

-- sea swell under the hull
local sea = c:ellipse(31, 55, 25, 4)
sea:cut(c:rect(0, 58, 63, 63))
local sb = {}
sea:each(function(x, y) if y >= 56 then sb[K(x, y)] = -1 end end)
O.shade(c, sea, SEA, { R = 2, bias = sb, amb = .35, wrap = .4, cuts = { .3, .5, .7, .88 } })
for _, w in ipairs({ { 8, 54 }, { 11, 53 }, { 44, 53 }, { 47, 54 }, { 26, 57 }, { 29, 57 } }) do O.dot(c, w[1], w[2], SEA[5]) end

-- mast
O.shade(c, c:rect(31, 6, 32, 38), WOOD, { R = 1, amb = .3 })
O.dots(c, { { 31, 14 }, { 32, 22 }, { 31, 30 } }, WOOD[2]) -- driftwood knots
-- palm-frond sail, bellied to the right
local sail = c:poly{ { 33, 6 }, { 42, 9 }, { 49, 15 }, { 53, 24 }, { 52, 31 }, { 46, 33 }, { 33, 33 } }
local lb = {}
sail:each(function(x, y)
  -- leaflet splits: diagonal grooves running down-right from the midrib
  if (y - x * .55) % 4 < 1 and x > 35 then lb[K(x, y)] = -2 end
  if math.abs((y - 6) - (x - 33) * 1.25) < .7 then lb[K(x, y)] = 2 end -- midrib
end)
O.shade(c, sail, LEAF, { R = 4, bias = lb, amb = .2, wrap = .35, sep = LEAF[1] })
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
O.shade(c, hull, HUSK, { sphere = { 24, 38, 24 }, bias = hb, amb = .2, wrap = .35 })
-- frayed fibre tufts sticking out of the hull silhouette
O.dots(c, { { 9, 41 }, { 53, 42 }, { 51, 49 } }, HUSK[3])
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

-- quirk: message in a bottle
local bot = c:rrect(51, 50, 58, 53, 1)
O.shade(c, bot, GLAS, { R = 1, amb = .4, cuts = { .4, .75 } })
O.flat(c, c:rect(59, 51, 60, 52), WOOD[2], "cork")
O.dots(c, { { 53, 51 }, { 54, 51 }, { 55, 51 }, { 53, 52 }, { 54, 52 } }, MEAT[3])
O.dot(c, 52, 50, SEA[5])

O.done(c, "cocopaddle-yard")
