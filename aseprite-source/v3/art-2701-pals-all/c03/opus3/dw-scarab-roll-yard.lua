-- Scarab Roll (dw-scarab-roll), yard sprite 64x64. Opus second pass (art-2701-pals-all/c03/opus3), built on the
-- Haiku first pass. Common, wayfinder, Dunewhisper. "Rolls a tiny ball of sand across the dunes at a steady pace."
-- An iridescent scarab in side view (teal into green with a violet bounce): domed elytra with a seam and curved
-- striae, a big round thorax that carries the face, a toothed shovel head, clubbed antenna, six sturdy dark legs
-- (2 px, jointed), both front legs braced on a sand ball as big as its thorax. The first pass's legs and eye
-- were tiny. quirk: a gold coin it picked up on the way is stuck in the sand ball (now 4x4 with a shine).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-scarab-roll-yard", 64)

local SCB  = { "#1c2244", "#1f4664", "#22706e", "#2e9a80", "#6cc89a", "#bdeec4" }
local LEG  = { "#1a1630", "#2c2a48", "#46466a", "#646a8a" }
local SND  = { "#6a4626", "#986a3a", "#c49254", "#dcb474", "#eed29c", "#f8eac8" }
local GOLD = { "#7a4a14", "#c08a22", "#f0c440", "#fde89a" }

c:groundShadow(31, 57, 26, 2.5)

local function leg(pts) O.shade(c, c:line(pts, 2), LEG, { R = 1, amb = .35, cuts = { .3, .55, .8 } }) end
-- far-side legs (behind)
leg({ { 40, 48 }, { 44, 52 }, { 47, 55 } })
leg({ { 31, 48 }, { 30, 52 }, { 28, 55 } })

-- sand ball
local ball = c:ellipse(12.5, 44, 10.5, 10.5)
local sI, sT = O.shade(c, ball, SND, { sphere = { 9, 41, 12 }, amb = .2, wrap = .4, sep = SND[1], rim = true, bounce = "#b07a8a", bmax = 2 })
O.tex(c, sI, sT, SND, function(x, y, i)
  local h = H(x, y, 11)
  if h > .86 and i <= 5 then return 1 end
  if h < .12 and i >= 2 then return -1 end
end)
-- quirk: a gold coin pressed into the ball
O.shade(c, c:ellipse(9, 39, 2.5, 2.5), GOLD, { R = 1, amb = .4, cuts = { .3, .6, .85 }, sep = GOLD[1] })
O.dot(c, 8, 38, GOLD[4]) O.dot(c, 9, 39, GOLD[2]) O.dot(c, 10, 39, GOLD[2])

-- elytra dome
local ely = c:ellipse(43, 40, 13.5, 12)
ely:cut(c:rect(28, 50, 58, 60))
local eI, eT = O.shade(c, ely, SCB, { sphere = { 39, 33, 17 }, amb = .2, wrap = .4, sep = SCB[1], rim = true, bounce = "#7a5ab0", bmax = 2 })
O.tex(c, eI, eT, SCB, function(x, y, i) -- striae: curved grooves following the dome
  local d = math.sqrt((x - 43)^2 * .9 + (y - 49)^2)
  if math.floor(d) % 4 == 0 and y < 48 and i >= 2 then return -1 end
end)
for y = 30, 49 do local x = 33 + math.floor((y - 32) * .15) if ely:has(x, y) then c:put(x, y, SCB[1], eT) end end -- seam
O.dots(c, { { 38, 32 }, { 39, 32 }, { 40, 31 } }, SCB[6]) -- specular

-- near-side legs
leg({ { 48, 49 }, { 52, 52 }, { 55, 56 } })
leg({ { 38, 50 }, { 38, 53 }, { 36, 56 } })

-- thorax (carries the face)
local th = c:ellipse(28, 41, 9, 9)
local tI, tT = O.shade(c, th, SCB, { sphere = { 25, 38, 11 }, amb = .22, wrap = .4, sep = SCB[1], rim = true, bounce = "#7a5ab0", bmax = 2 })
-- toothed shovel head, pressing the ball
local hd = c:poly{ { 21, 44 }, { 25, 46 }, { 25, 50 }, { 20, 50 }, { 19, 47 } }
O.shade(c, hd, SCB, { R = 1, amb = .3, sep = SCB[1] })
O.dots(c, { { 20, 50 }, { 22, 50 }, { 24, 50 } }, SCB[2])
-- front legs braced on the ball
leg({ { 22, 41 }, { 19, 38 }, { 18, 35 } })
leg({ { 26, 49 }, { 23, 53 }, { 20, 54 } })
-- clubbed antenna
O.flat(c, c:line({ { 24, 33 }, { 22, 30 }, { 21, 28 } }, 1), LEG[3], "antenna")
O.dots(c, { { 19, 26 }, { 20, 27 }, { 18, 28 }, { 19, 28 }, { 20, 26 } }, LEG[4]) O.dot(c, 19, 27, LEG[2]) -- fanned club

-- face
c:eyeLocked(21, 38) c:eyeLocked(28, 38)
c:cheek(20, 44) c:cheek(32, 44)
O.dots(c, { { 25, 45 }, { 26, 46 }, { 27, 46 }, { 28, 45 } }, P.ink)

O.done(c, "dw-scarab-roll-yard", function(c)
  -- steady-pace dust kicked up behind
  for _, d in ipairs({ { 58, 54 }, { 60, 52 }, { 61, 55 } }) do c:put(d[1], d[2], SND[4]) end
end)
