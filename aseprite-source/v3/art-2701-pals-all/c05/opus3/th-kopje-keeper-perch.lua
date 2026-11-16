-- Kopje Keeper (th-kopje-keeper), perch sprite 36x36. Opus richness pass (c05/opus3), hand-built at this size.
-- Richness pass: hue-shifted granite ramp, feldspar and mica flecks, orange and sage lichen. Fix vs opus2 (lizard
-- too small at 1x): the agama is now 2 px thick and 14 px long with a 3x3 orange head on straight front legs,
-- tail curling down the top boulder, so it reads at 36 px.
-- Bold and few: wide warm-granite boulder with a smaller boulder balanced on top and a pebble at its foot,
-- one exfoliation curve, two lichen spots, wide pill eyes under a lit ledge, flat watchful mouth.
-- quirk: the blue-and-orange agama lizard on the top boulder.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-kopje-keeper-perch", 36)

local GRAN = { "#352433", "#5a3f48", "#83605c", "#a88370", "#cba78a", "#e8cfae" }
local LIZ  = { "#1d2f5e", "#2f55a0", "#4f86d0", "#86b8ec" }
local LHD  = { "#8a3a1a", "#d8682a", "#f4a050" }
local LICH = { "#b8682a", "#e0913a", "#f4bc6a" }
local BNC  = "#6a6688"

c:groundShadow(18, 32, 12, 1.5)
O.shade(c, c:ellipse(27.5, 29.5, 3, 2), GRAN, { R = 1, amb = .3, sep = GRAN[1], rim = true })
local big = c:ellipse(17, 23.5, 10, 7.5)
big:cut(c:rect(0, 31, 35, 35))
local bb = {} big:each(function(x, y) if y >= 30 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, big, GRAN, { sphere = { 14, 20, 13 }, bias = bb, amb = .22, wrap = .35, sep = GRAN[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, GRAN, function(x, y, i)
  if x > 10 and x < 24 and y > 18 and y < 27 then return nil end
  local h = H(x, y, 21)
  if h > .9 and i >= 2 and i <= 5 then return 1 end
end)
O.mark(c, { { 23, 28 }, { 24, 27 }, { 25, 26 }, { 26, 25 } }, GRAN[2]) O.mark(c, { { 23, 27 }, { 24, 26 }, { 25, 25 } }, GRAN[4])
O.mark(c, { { 9, 26 }, { 10, 26 } }, LICH[2]) O.mark(c, { { 22, 18 } }, LICH[3])
O.mark(c, { { 25, 21 }, { 26, 22 } }, "#a8b894")
O.mark(c, { { 9, 21 }, { 14, 28 }, { 21, 29 }, { 24, 23 } }, "#e0a08e") O.mark(c, { { 11, 28 }, { 25, 19 } }, GRAN[1])

local top = c:ellipse(15, 12.5, 6, 4)
local tb = {} top:each(function(x, y) if y >= 15 then tb[K(x, y)] = -1 end end)
O.shade(c, top, GRAN, { sphere = { 13, 11, 7 }, bias = tb, amb = .25, wrap = .35, sep = GRAN[1], rim = true, bounce = BNC, bmax = 2 })

O.mark(c, { { 11, 18 }, { 12, 18 }, { 13, 18 }, { 19, 18 }, { 20, 18 }, { 21, 18 } }, GRAN[6])
O.mark(c, { { 12, 19 }, { 13, 19 }, { 19, 19 }, { 20, 19 } }, GRAN[2])
c:eyeSmall(12, 20) c:eyeSmall(19, 20)
O.dot(c, 10, 24, "#f5809f") O.dot(c, 23, 24, "#f5809f")
O.mark(c, { { 14, 25 }, { 15, 25 }, { 16, 25 }, { 17, 25 }, { 18, 25 } }, P.ink)

-- agama on the top boulder: push-up pose, 2 px blue body, orange head, banded tail down the right side
local LZ = c:rect(13, 7, 19, 8)
O.shade(c, LZ, LIZ, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = GRAN[1] })
O.dots(c, { { 14, 7 }, { 16, 7 }, { 18, 7 } }, LIZ[4])
O.flat(c, c:line({ { 20, 8 }, { 21, 9 }, { 22, 11 }, { 22, 13 } }, 1), LIZ[2], "tail") O.dots(c, { { 21, 9 }, { 22, 12 } }, LIZ[4])
O.flat(c, c:rect(12, 9, 12, 9), LIZ[1], "legs") O.flat(c, c:rect(18, 9, 18, 9), LIZ[1], "legs")
O.shade(c, c:rect(9, 5, 12, 7), LHD, { R = 1, amb = .45, cuts = { .35, .7 }, sep = LIZ[1] })
O.dot(c, 10, 5, LHD[3]) O.dot(c, 11, 6, P.ink) O.dot(c, 9, 7, LHD[1])

O.shift(c, 1, 0)
O.done(c, "th-kopje-keeper-perch")
