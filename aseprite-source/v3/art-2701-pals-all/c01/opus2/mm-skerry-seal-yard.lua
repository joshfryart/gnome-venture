-- Skerry Seal (mm-skerry-seal), yard sprite 64x64. Opus second pass (art-2701-pals-all/c01/opus2), from the Haiku idea.
-- Wayfinder, common, Mistmoor. "Barks at the lighthouse and waits for a fish to be invented."
-- A spotted harbour seal hauled out on a wet skerry (dark rock, barnacles, wrack weed, sea lapping round it),
-- head up and mouth open mid-bark, two bark ticks flying toward a small red-and-cream lighthouse on the rock's
-- far end, its lamp lit.
-- Fixes: the Haiku seal head was the weakest part and the lighthouse read as a spray bottle; now the head is a
-- big rounded 3/4 face with a muzzle, whisker pads and an open mouth, and the lighthouse has a striped tower,
-- gallery, glowing lamp room and dome.
-- quirk: a fish that has not been invented yet: a dotted pencil outline of a fish, waiting, above its head.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mm-skerry-seal-yard", 64)

local SEAL = { "#2e2a3c", "#4a4458", "#6c6474", "#928a96", "#b8b0b6", "#dcd4d2" }
local BELY = { "#8a8494", "#b4aeb8", "#d8d2d4", "#ece6e2" }
local ROCK = { "#1e1e2e", "#2e3044", "#454a60", "#62687e", "#8288a0", "#a8aec0" }
local SEA  = { "#1d3f63", "#25628a", "#2f8fae", "#4fbcc4", "#8ee0d4", "#d2f6ea" }
local WRK  = { "#3a3a1c", "#6a6224", "#9a8a30" }
local LH   = { "#7c1c34", "#c43a3a", "#ea6a52" }
local CRM  = { "#a8a0a0", "#d8d0c8", "#f4ece0" }
local LAMP = { "#c98322", "#f5b82e", "#ffe38a" }

-- sea around the foot of the skerry
local sea = c:ellipse(32, 55, 26, 3)
sea:each(function(x, y)
  local col = y <= 54 and SEA[4] or SEA[3]
  if y >= 57 then col = SEA[2] end
  if y == 54 and H(x, y, 5) > .6 then col = SEA[6] end
  c:put(x, y, col, { r = { name = "sea" } })
end)

-- the skerry
local rock = c:poly{ { 7, 54 }, { 10, 48 }, { 16, 45 }, { 26, 44 }, { 40, 44 }, { 48, 43 }, { 54, 45 }, { 57, 50 }, { 56, 54 } }
local rI, rT = O.shade(c, rock, ROCK, { R = 3, amb = .15, wrap = .3, sep = ROCK[1], rim = true })
O.tex(c, rI, rT, ROCK, function(x, y, i)
  if H(x, y, 9) > .9 and i >= 2 and i <= 5 then return 1 end
  if y >= 52 then return -1 end -- wet band at the waterline
end)
for _, b in ipairs({ { 12, 49 }, { 15, 51 }, { 46, 49 }, { 51, 48 }, { 53, 51 } }) do -- barnacles
  O.dot(c, b[1], b[2], CRM[2]) O.dot(c, b[1] + 1, b[2], CRM[1]) O.dot(c, b[1], b[2] + 1, ROCK[2])
end
for x = 9, 55, 2 do -- wrack weed fringe at the waterline
  if H(x, 0, 6) > .35 then O.dot(c, x, 53, WRK[2]) O.dot(c, x, 52, WRK[3]) O.dot(c, x + 1, 53, WRK[1]) end
end

-- lighthouse on the far end of the rock
local tower = c:poly{ { 47, 44 }, { 48, 24 }, { 53, 24 }, { 54, 44 } }
local tn = O.cylN(tower, 50.5, 3.5, -.1)
local tv = X.light(tn, { amb = .2, wrap = .35 })
local ttok = { r = { name = "tower" } }
tower:each(function(x, y)
  local v = tv[K(x, y)] or .5
  local band = ((y - 24) // 5) % 2 == 0
  local R = band and LH or CRM
  local i = v < .45 and 1 or (v < .75 and 2 or 3)
  c:put(x, y, R[i], ttok)
end)
O.dots(c, { { 50, 35 }, { 50, 36 } }, ROCK[1]) -- window
O.shade(c, c:rect(46, 22, 55, 23), ROCK, { R = 1, amb = .3, sep = ROCK[1] }) -- gallery
local lamp = c:rect(48, 18, 53, 21)
lamp:each(function(x, y) c:put(x, y, (x == 49 or x == 50) and LAMP[3] or LAMP[2], { r = { name = "lamp" } }) end)
O.dots(c, { { 48, 18 }, { 48, 19 }, { 48, 20 }, { 48, 21 }, { 53, 18 }, { 53, 19 }, { 53, 20 }, { 53, 21 } }, ROCK[2]) -- glazing bars
O.dots(c, { { 51, 18 }, { 51, 19 }, { 51, 20 }, { 51, 21 } }, LAMP[1])
local dome = c:ellipse(50.5, 17, 3.5, 2)
dome:cut(c:rect(40, 18, 60, 30))
O.shade(c, dome, LH, { R = 1, amb = .3, cuts = { .4, .75 } })
O.dot(c, 50, 14, LH[2])

-- the seal: tail flippers, body lying on the rock, neck up, head raised
local tail = c:poly{ { 9, 38 }, { 14, 41 }, { 17, 44 }, { 12, 44 }, { 8, 43 } }
O.shade(c, tail, SEAL, { R = 1, amb = .2, sep = SEAL[1], rim = true })
local body = c:ellipse(26, 40, 14, 5.5)
body:add(c:poly{ { 26, 36 }, { 30, 28 }, { 40, 28 }, { 41, 40 }, { 34, 45 } })
local sI, sT = O.shade(c, body, SEAL, { R = 5, amb = .15, wrap = .35, sep = SEAL[1], rim = true, bounce = "#4f7a9a", bmax = 2 })
-- harbour-seal spots
O.tex(c, sI, sT, SEAL, function(x, y, i)
  if y > 41 then return end
  local h = H(x // 2, y // 2, 33)
  if h > .82 and i >= 2 then return -1 end
end)
-- pale belly along the bottom of the body/neck
local bel = c:ellipse(30, 43, 9, 2)
bel:add(c:poly{ { 34, 31 }, { 39, 31 }, { 39, 41 }, { 33, 42 } })
bel:clip(body)
O.shade(c, bel, BELY, { R = 2, amb = .35, cuts = { .3, .55, .8 } })
-- front flipper
local fl = c:poly{ { 35, 41 }, { 39, 42 }, { 42, 45 }, { 36, 45 } }
O.shade(c, fl, SEAL, { R = 1, amb = .2, sep = SEAL[1] })

-- head (3/4, tilted up toward the lighthouse)
local head = c:ellipse(35, 23, 8.5, 7)
local hI, hT = O.shade(c, head, SEAL, { R = 4, amb = .2, wrap = .35, sep = SEAL[1], rim = true, bounce = "#4f7a9a", bmax = 2 })
local muz = c:ellipse(37, 28, 4.5, 2.5)
O.shade(c, muz, BELY, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
-- whisker dots
O.dots(c, { { 34, 28 }, { 35, 29 }, { 39, 28 }, { 40, 29 } }, SEAL[2])
-- nose
O.dots(c, { { 36, 26 }, { 37, 26 }, { 38, 26 } }, SEAL[1]) O.dot(c, 37, 27, SEAL[1]) O.dot(c, 36, 26, SEAL[3])
-- open barking mouth
O.dots(c, { { 36, 29 }, { 37, 29 }, { 38, 29 }, { 36, 30 }, { 37, 30 }, { 38, 30 }, { 37, 31 } }, P.ink)
O.dots(c, { { 37, 30 } }, "#e86a7a")
c:eyeLocked(29, 19)
c:eyeLocked(37, 18)
c:cheek(28, 26)

O.done(c, "mm-skerry-seal-yard", function(c)
  -- bark ticks flying toward the lighthouse (un-outlined)
  for _, p in ipairs({ { 43, 25 }, { 44, 24 }, { 43, 28 }, { 44, 28 }, { 45, 28 } }) do c:put(p[1], p[2], "#eef3f8") end
  -- the uninvented fish: a dotted pencil outline, nothing inside
  local fish = { { 14, 21 }, { 16, 20 }, { 18, 19 }, { 20, 19 }, { 22, 20 }, { 23, 22 }, { 22, 24 }, { 20, 25 }, { 18, 25 },
                 { 16, 24 }, { 14, 23 }, { 12, 21 }, { 11, 19 }, { 11, 25 }, { 12, 24 } }
  for _, p in ipairs(fish) do c:put(p[1], p[2], "#d9e3ee") end
  c:put(20, 21, "#d9e3ee")
end)
