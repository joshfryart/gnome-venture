-- Scarab Roll (dw-scarab-roll), yard sprite 64x64. Opus richness pass (c03/opus3), built on c03/opus2.
-- Common, wayfinder, Dunewhisper. "Rolls a tiny ball of sand across the dunes at a steady pace."
-- Richness pass, and the opus2 weakness fixed (the yard was wide and low with empty space on top): the pose is now
-- a proper pushing stance, rear end raised and the elytra dome lifted high, a bigger sand ball, a taller antenna,
-- so the sprite fills the cell. Elytra: hue-shifted iridescence (teal crown, green flank, violet underside rim),
-- curved striae with lit ridges, a specular arc; punctate pronotum; the ball has pebbles, a straw bit and grit.
-- quirk: a gold coin it picked up on the way is stuck in the ball. closer look: a neat line of tiny footprints
-- trails off behind it, perfectly evenly spaced (a steady pace).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-scarab-roll-yard", 64)

local SCB  = { "#1a1e40", "#1c4262", "#1e6a6c", "#2a967e", "#62c496", "#b6ecc0" }
local VIOL = { "#2e2250", "#4e3a86" }
local LEG  = { "#181428", "#2a2846", "#444468", "#646a8a" }
local SND  = { "#62402a", "#93663a", "#c08e52", "#dab272", "#eed09a", "#f8e8c4" }
local GOLD = { "#7a4a14", "#c08a22", "#f0c440", "#fde89a" }
local STRW = "#e6c66a"

c:groundShadow(31, 58, 27, 2.5)

local function leg(pts)
  local m = c:line(pts, 2)
  local i2, t2 = O.shade(c, m, LEG, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
  return m
end
-- far-side legs (behind)
leg({ { 43, 46 }, { 47, 51 }, { 50, 56 } })
leg({ { 34, 48 }, { 33, 52 }, { 31, 56 } })

-- sand ball, bigger
local ball = c:ellipse(14.5, 43, 12.5, 12.5)
local sI, sT = O.shade(c, ball, SND, { sphere = { 10, 38, 15 }, amb = .2, wrap = .4, sep = SND[1], rim = true, bounce = "#b07a8a", bmax = 2 })
O.tex(c, sI, sT, SND, function(x, y, i)
  local h = H(x, y, 11)
  if h > .9 and i <= 5 then return 1 end                    -- grit glints
  if h < .1 and i >= 2 then return -1 end                    -- grit pits
  if (x // 3 + y // 3) % 5 == 0 and H(x // 3, y // 3, 7) > .6 and i >= 3 then return -1 end -- packed clumps
end)
-- pebbles pressed into the ball (lit top, dark under)
for _, pb in ipairs({ { 18, 50 }, { 6, 47 }, { 21, 36 } }) do
  O.mark(c, { { pb[1], pb[2] }, { pb[1] + 1, pb[2] } }, SND[6]) O.mark(c, { { pb[1], pb[2] + 1 }, { pb[1] + 1, pb[2] + 1 } }, SND[2])
end
-- a straw bit stuck in the sand
O.mark(c, { { 12, 52 }, { 13, 51 }, { 14, 51 }, { 15, 50 } }, STRW) O.mark(c, { { 13, 52 }, { 15, 51 } }, SND[2])
-- quirk: a gold coin pressed into the ball (rim, face, shine)
local coin = c:ellipse(9, 38, 3, 3)
local gI, gT = O.shade(c, coin, GOLD, { R = 1, amb = .4, cuts = { .3, .6, .85 }, sep = GOLD[1] })
O.mark(c, { { 8, 37 }, { 7, 38 } }, GOLD[4]) O.mark(c, { { 9, 38 }, { 10, 38 }, { 9, 39 } }, GOLD[2]) -- stamped dot

-- elytra dome, rear raised
local ely = c:ellipse(45, 34.5, 14, 13)
ely:cut(c:poly{ { 30, 48 }, { 60, 42 }, { 63, 63 }, { 30, 63 } })
local eI, eT = O.shade(c, ely, SCB, { sphere = { 40, 28, 18 }, amb = .2, wrap = .4, sep = SCB[1], rim = true, bounce = VIOL[2], bmax = 2 })
O.tex(c, eI, eT, SCB, function(x, y, i) -- striae: curved grooves with a lit ridge beside each
  local d = math.sqrt((x - 46)^2 * .8 + (y - 50)^2)
  local f = math.floor(d) % 4
  if f == 0 and i >= 2 then return -1 end
  if f == 1 and i >= 3 and i <= 5 then return 1 end
end)
-- iridescent underside rim: violet in the deepest shade along the lower edge
ely:each(function(x, y)
  local p = y * c.w + x
  if c.own[p] == eT and not ely:has(x, y + 2) and c.pix[p] == SCB[1]:lower() then c.pix[p] = VIOL[1] end
  if c.own[p] == eT and not ely:has(x, y + 2) and c.pix[p] == SCB[2]:lower() then c.pix[p] = VIOL[2] end
end)
for y = 22, 47 do local x = 34 + math.floor((y - 22) * .12) if ely:has(x, y) then c:put(x, y, SCB[1], eT) end end -- seam
O.dots(c, { { 39, 25 }, { 40, 24 }, { 41, 24 }, { 42, 23 }, { 38, 26 } }, SCB[6]) -- specular arc

-- near-side legs
leg({ { 51, 45 }, { 55, 50 }, { 58, 56 } })
leg({ { 41, 49 }, { 41, 53 }, { 39, 56 } })

-- thorax (pronotum carries the face), punctate
local th = c:ellipse(30.5, 40, 9.5, 9.5)
local tI, tT = O.shade(c, th, SCB, { sphere = { 27, 36, 12 }, amb = .22, wrap = .4, sep = SCB[1], rim = true, bounce = VIOL[2], bmax = 2 })
O.tex(c, tI, tT, SCB, function(x, y, i)
  local face = x > 22 and x < 39 and y > 35 and y < 47
  if not face and H(x, y, 13) > .82 and i >= 3 then return -1 end
end)
O.dots(c, { { 25, 33 }, { 26, 32 }, { 27, 32 } }, SCB[6])
-- toothed shovel head, pressing the ball
local hd = c:poly{ { 23, 44 }, { 27, 46 }, { 27, 51 }, { 21, 51 }, { 20, 48 } }
O.shade(c, hd, SCB, { R = 1, amb = .3, sep = SCB[1] })
O.dots(c, { { 21, 51 }, { 23, 51 }, { 25, 51 } }, SCB[2])
-- front legs braced on the ball, with tibial teeth
leg({ { 23, 41 }, { 20, 37 }, { 19, 33 } })
O.dots(c, { { 18, 35 }, { 18, 37 } }, LEG[4])
leg({ { 28, 49 }, { 25, 53 }, { 21, 55 } })
-- clubbed antenna, fanned lamellae
O.flat(c, c:line({ { 26, 32 }, { 24, 28 }, { 22, 25 } }, 1), LEG[3], "antenna")
O.dots(c, { { 19, 22 }, { 20, 23 }, { 21, 22 }, { 21, 21 }, { 22, 22 }, { 20, 21 } }, LEG[4]) O.dots(c, { { 20, 22 }, { 21, 23 } }, LEG[2])

-- face
c:eyeLocked(23, 37) c:eyeLocked(31, 37)
c:cheek(22, 43) c:cheek(36, 43)
O.dots(c, { { 27, 44 }, { 28, 45 }, { 29, 45 }, { 30, 45 }, { 31, 44 } }, P.ink)

O.done(c, "dw-scarab-roll-yard", function(c)
  -- steady-pace dust kicked up behind, and (closer look) an even line of tiny footprints trailing off
  for _, d in ipairs({ { 60, 52 }, { 62, 50 }, { 61, 54 } }) do if not c:get(d[1], d[2]) then c:put(d[1], d[2], SND[4]) end end
  for _, fx in ipairs({ 60, 62 }) do c:put(fx, 59, SND[2]) c:put(fx + 1, 60, SND[2]) end
end)
