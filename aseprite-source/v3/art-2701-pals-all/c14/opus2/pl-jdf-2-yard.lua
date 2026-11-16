-- Reedleg Cling (pl-jdf-2), yard sprite 64x64. Opus second pass (c14/opus2), built on c14/haiku.
-- Seedkeeper, common, Lair of the Jade Dragon-fly. "Holds onto the reeds with six tiny legs and will not let go."
-- Haiku drew a brown egg with stick legs between two green poles. It is now a jade dragonfly nymph (the young
-- dragonfly, before it has wings): a broad head with big bulging eyes, a thorax with two little wing pads, a
-- banded, tapering abdomen ending in three tail spikes, and six jointed legs, three a side, each clamped round
-- a dry golden reed. The right reed carries a cattail head.
-- quirk: it will not let go: knuckled claws dug into both reeds, the reeds bowed in toward it, a bead of
-- effort sweat on its brow.
-- closer look: a dewdrop sliding down the left reed.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-jdf-2-yard", 64)

local NYM  = { "#143632", "#1e5446", "#2c7a5e", "#4aa078", "#80c692", "#bce6b8" }
local REED = { "#4a3426", "#6e5030", "#987440", "#c09c58", "#dcc07a", "#f0dca4" }
local CAT  = { "#3a2224", "#5a3426", "#7e4c30", "#a46a40", "#c88c58" }
local CLAW = "#3a2a24"
local DEW  = { "#5aa0c8", "#a8dcf0", "#e6f6fa" }

c:groundShadow(32, 58, 22, 2)

-- the two reeds, bowed in toward the nymph
local reeds = {}
for _, R in ipairs({ { { 15, 58 }, { 17, 40 }, { 15, 22 }, { 9, 6 } }, { { 49, 58 }, { 47, 40 }, { 49, 24 }, { 53, 12 } } }) do
  local m, n, T = O.tube(R, function(t) return 2.3 - .6 * t end)
  local I, Tk = O.shadeN(c, m, n, REED, { amb = .32, wrap = .45, rim = true, bounce = "#7a6a90", bmax = 2, sep = REED[1] })
  O.tex(c, I, Tk, REED, function(x, y, i) local t = T[K(x, y)] if t and (t * 6) % 1 < .06 then return -2 end end) -- reed nodes
  reeds[#reeds+1] = m
end
-- cattail head on the right reed
local cat = c:rrect(50, 9, 55, 20, 2)
local cI, cT = O.shade(c, cat, CAT, { R = 2, amb = .35, wrap = .45, sep = CAT[1], cuts = { .25, .45, .65, .85 } })
O.tex(c, cI, cT, CAT, function(x, y, i) if H(x, y, 4) > .8 then return 1 end end) -- fluff flecks
O.dots(c, { { 53, 6 }, { 53, 7 }, { 53, 8 } }, REED[3]) -- spike above the cattail

-- legs, three a side, femur up and out, tibia down onto the reed, claws dug in
local feet = {}
for _, L in ipairs({ { 25, 31, 15, 29 }, { 25, 36, 16, 37 }, { 26, 41, 17, 45 }, { 38, 31, 48, 29 }, { 38, 36, 47, 37 }, { 37, 41, 47, 45 } }) do
  local sx, sy, ex, ey = L[1], L[2], L[3], L[4]
  local kx, ky = (sx + ex) / 2, math.min(sy, ey) - 5
  local m, n = O.tube({ { sx, sy }, { kx, ky }, { kx, ky }, { ex, ey } }, function(t) return 1.25 - .35 * t end)
  O.shadeN(c, m, n, NYM, { amb = .32, wrap = .45, sep = NYM[1], cuts = { .22, .4, .56, .72, .86 } })
  O.dot(c, math.floor(kx + .5), math.floor(ky + 1.5), NYM[6]) -- knee
  feet[#feet+1] = { ex, ey }
end
for _, f in ipairs(feet) do O.dots(c, { { f[1], f[2] + 1 }, { f[1] + (f[1] < 32 and -1 or 1), f[2] + 1 } }, CLAW) end

-- abdomen: banded segments tapering down to three tail spikes
local abd = c:ellipse(32, 47, 6, 9)
abd:add(c:poly{ { 29, 52 }, { 35, 52 }, { 32, 57 } })
local aI, aT = O.shade(c, abd, NYM, { sphere = { 30, 43, 11 }, amb = .3, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 2, sep = NYM[1] })
O.tex(c, aI, aT, NYM, function(x, y, i) if (y - 40) % 3 == 0 and y > 40 then return -2 end if (y - 40) % 3 == 1 and y > 40 and i >= 3 then return 1 end end)
O.dots(c, { { 30, 57 }, { 29, 58 }, { 34, 57 }, { 35, 58 }, { 32, 58 }, { 32, 59 } }, NYM[2]) -- tail spikes
-- thorax with two wing pads
local thx = c:ellipse(32, 36, 7, 5.5)
local tI, tT = O.shade(c, thx, NYM, { sphere = { 29, 33, 9 }, amb = .32, wrap = .45, rim = true, sep = NYM[1] })
O.shade(c, c:poly{ { 28, 36 }, { 31, 35 }, { 31, 43 }, { 29, 42 } }, NYM, { R = 1, amb = .45, wrap = .5, sep = NYM[1] })
O.shade(c, c:poly{ { 33, 35 }, { 36, 36 }, { 35, 42 }, { 33, 43 } }, NYM, { R = 1, amb = .45, wrap = .5, sep = NYM[1] })
-- head: broad, with the bulging eyes on top
local head = c:ellipse(32, 25, 10, 7)
local hI, hT = O.shade(c, head, NYM, { sphere = { 28, 20, 13 }, amb = .32, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 2, sep = NYM[1] })
for _, e in ipairs({ { 25, 19 }, { 39, 19 } }) do
  O.shade(c, c:ellipse(e[1], e[2], 4, 3.5), NYM, { sphere = { e[1] - 2, e[2] - 2, 6 }, amb = .4, wrap = .5, sep = NYM[1] })
end
c:eyeLocked(23, 17)
c:eyeLocked(37, 17)
c:cheek(24, 26) c:cheek(38, 26)
-- clenched determined mouth (the nymph's folded jaw)
O.dots(c, { { 28, 28 }, { 29, 28 }, { 30, 28 }, { 31, 28 }, { 32, 28 }, { 33, 28 }, { 34, 28 }, { 35, 28 } }, P.ink)
O.dots(c, { { 29, 29 }, { 34, 29 } }, P.ink)
O.dots(c, { { 30, 29 }, { 31, 29 }, { 32, 29 }, { 33, 29 } }, NYM[2])
O.dots(c, { { 27, 23 }, { 28, 22 }, { 36, 22 }, { 37, 23 } }, NYM[2]) -- furrowed brow

-- dewdrop on the left reed
O.dot(c, 15, 50, DEW[1]) O.dot(c, 15, 49, DEW[2]) O.dot(c, 14, 49, DEW[3])

O.done(c, "pl-jdf-2-yard", function(c)
  O.dots(c, { { 43, 14 }, { 43, 15 }, { 44, 15 }, { 42, 16 }, { 43, 16 }, { 44, 16 }, { 43, 17 } }, DEW[2]) -- bead of effort sweat
  O.dot(c, 42, 15, DEW[3]) O.dot(c, 44, 17, DEW[1])
end)
