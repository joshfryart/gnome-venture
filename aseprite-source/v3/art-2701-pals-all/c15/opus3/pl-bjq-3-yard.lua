-- Bell Bead (pl-bjq-3), yard sprite 64x64. Opus richness pass (c15/opus3), built on c15/opus2.
-- Bloomcaller, common, Reef of the Box-Jelly Queen. "A tiny blue bell that only rings when the queen is near."
-- A blue sea-glass bell: round crown, flared waist and a rolled lip band, glass cues (bright rim, pale streak down
-- the left, darker core), a gold ring on top tied with a little pink ribbon bow, and a gold bead clapper below.
-- It bobs above the sand (ground shadow under it).
-- Haiku weakness fixed: a flat cyan cone with an aerial spike and a floating ball; now a proper bell silhouette
-- (crown, waist, flared lip), glassy material, a ring hanger and a clapper swinging inside the mouth.
-- quirk: the queen must be near: mid-ding, clapper swung to one side, ring arcs on that side only.
-- richness: hue-shifted sea-glass ramp (indigo deeps, ice-mint lights), frosted sea-glass speckle, two tiny
-- trapped air bubbles in the glass, ribbon tails hanging from the bow, a glint on the gold clapper bead, rim light
-- upper-left and lilac bounce lower-right.
-- closer look: the queen's mark, a tiny gold crown pressed into the middle of the lip band.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-3-yard", 64)

local GLS  = { "#262c6a", "#2f569e", "#4886c8", "#76b8e4", "#ace0f2", "#e2f8f6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4c0" }
local RIB  = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

c:groundShadow(31, 56, 12, 2)

-- clapper on a short stem, swung to the right (drawn first; the lip overlaps its stem)
O.flat(c, c:line({ { 32, 40 }, { 36, 47 } }, 1), GOLD[2], "stem")
O.shade(c, c:ellipse(37, 49, 3.5, 3.5), GOLD, { sphere = { 35, 47, 5 }, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 }, rim = true, sep = GOLD[1] })

-- ring hanger with a bow
local ring = c:ellipse(32, 10, 4, 4) ring:cut(c:ellipse(32, 10, 2, 2))
O.shade(c, ring, GOLD, { R = 1, amb = .35, wrap = .4, cuts = { .25, .45, .65, .85 }, rim = true })

-- bell body
local bell = c:ellipse(32, 23, 10, 9)
bell:add(c:poly{ { 22, 23 }, { 42, 23 }, { 44, 35 }, { 48, 41 }, { 16, 41 }, { 20, 35 } })
local bI, bT = O.shade(c, bell, GLS, { R = 7, amb = .26, wrap = .45, rim = true, bounce = "#9a7ad0", bmax = 2, sep = GLS[2] })
-- glass: darker inner core band, pale streak down the left, bright rim on the right edge
O.tex(c, bI, bT, GLS, function(x, y, i)
  local half = 10 + math.max(0, y - 23) * .5
  local u = (x + .5 - 32) / half
  if u > -.15 and u < .35 and y > 18 and i >= 3 then return -1 end
  if u > .78 and y > 20 and y < 38 then return 2 end
  if O.H(x, y, 41) > .9 and i >= 2 and i <= 4 then return 1 end -- frosted sea-glass speckle
end)
-- two tiny air bubbles trapped in the glass
for _, b in ipairs({ { 39, 31 }, { 21, 34 } }) do
  O.mark(c, { { b[1], b[2] - 1 }, { b[1] - 1, b[2] }, { b[1] + 1, b[2] }, { b[1], b[2] + 1 } }, GLS[5])
  O.mark(c, { { b[1] - 1, b[2] - 1 } }, GLS[6])
end
for y = 16, 37 do
  local x = 25 - math.floor(math.max(0, y - 24) * .45)
  O.mark(c, { { x, y } }, GLS[6])
end
O.mark(c, { { 27, 15 }, { 28, 15 }, { 26, 16 } }, GLS[6])
-- rolled lip band
local lip = c:rrect(15, 40, 49, 43, 1)
local lI, lT = O.shade(c, lip, GLS, { R = 2, amb = .3, wrap = .45, rim = true, sep = GLS[1] })
O.mark(c, { { 18, 40 }, { 19, 40 }, { 20, 40 }, { 21, 40 } }, GLS[6])
-- dark mouth slot under the lip (inside of the bell)
O.flat(c, c:rect(20, 44, 44, 45), GLS[1], "mouth")
O.dots(c, { { 20, 44 }, { 44, 44 }, { 20, 45 }, { 21, 45 }, { 43, 45 }, { 44, 45 } }, GLS[2])
-- re-draw the clapper bead in front of the mouth slot
O.shade(c, c:ellipse(37, 49, 3.5, 3.5), GOLD, { sphere = { 35, 47, 5 }, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 }, sep = GLS[1] })
O.mark(c, { { 36, 46 }, { 36, 47 } }, GOLD[2])
O.mark(c, { { 35, 47 } }, GOLD[5])
-- the queen's mark: a tiny gold crown pressed into the lip band
O.mark(c, { { 30, 41 }, { 32, 41 }, { 34, 41 }, { 30, 42 }, { 31, 42 }, { 32, 42 }, { 33, 42 }, { 34, 42 } }, GOLD[3])
O.mark(c, { { 32, 41 } }, GOLD[4])

-- pink ribbon bow on the ring
O.shade(c, c:poly{ { 31, 14 }, { 25, 11 }, { 25, 17 } }, RIB, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = RIB[1] })
O.shade(c, c:poly{ { 33, 14 }, { 39, 11 }, { 39, 17 } }, RIB, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = RIB[1] })
-- ribbon tails hanging from the knot
for _, row in ipairs({ { 16, 30 }, { 17, 30 }, { 18, 29 }, { 19, 29 }, { 20, 28 } }) do
  local y, x = row[1], row[2]
  O.dot(c, x, y, RIB[3]) O.dot(c, x + 1, y, RIB[2])               -- left tail (lit edge left)
  O.dot(c, 64 - x - 1, y, RIB[3]) O.dot(c, 64 - x, y, RIB[2])     -- right tail, mirrored
end
O.dots(c, { { 28, 21 }, { 36, 21 } }, RIB[1]) -- notched ends
O.shade(c, c:rect(31, 13, 33, 15), RIB, { R = 1, amb = .4, cuts = { .3, .55, .8 }, sep = RIB[1] })

-- face
c:eyeLocked(25, 24)
c:eyeLocked(34, 24)
c:cheek(23, 30) c:cheek(39, 30)
O.flat(c, c:rect(30, 31, 33, 32), P.ink, "mouth") O.dots(c, { { 30, 32 }, { 33, 32 } }, GLS[4]) O.dots(c, { { 31, 32 }, { 32, 32 } }, "#c94f84")

O.done(c, "pl-bjq-3-yard", function(c)
  local function put(x, y, h) if not c:get(x, y) then c:put(x, y, h) end end
  -- ring arcs on the clapper side only
  for _, p in ipairs({ { 52, 30 }, { 53, 31 }, { 53, 32 }, { 53, 33 }, { 52, 34 },
    { 55, 27 }, { 56, 28 }, { 57, 29 }, { 57, 30 }, { 57, 31 }, { 57, 32 }, { 57, 33 }, { 57, 34 }, { 56, 35 }, { 55, 36 } }) do put(p[1], p[2], P.ink) end
  c:sparkle(51, 22)
end)
