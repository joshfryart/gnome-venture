-- Kopje Keeper (th-kopje-keeper), perch sprite 36x36. Opus second pass (c05/opus2), hand-built at this size.
-- Bold and few: wide warm-granite boulder with a smaller boulder balanced on top and a pebble at its foot,
-- one exfoliation curve, two lichen spots, wide pill eyes under a lit ledge, flat watchful mouth.
-- quirk: the blue-and-orange agama lizard on the top boulder.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("th-kopje-keeper-perch", 36)

local GRAN = { "#3b2a2e", "#5e4344", "#86625a", "#a98472", "#c9a68c", "#e4c8a8" }
local LIZ  = { "#1d2f5e", "#2f55a0", "#4f86d0", "#86b8ec" }
local LHD  = { "#8a3a1a", "#d8682a", "#f4a050" }
local LICH = { "#b8682a", "#e0913a", "#f4bc6a" }
local BNC  = "#6a6688"

c:groundShadow(18, 32, 12, 1.5)
O.shade(c, c:ellipse(27.5, 29.5, 3, 2), GRAN, { R = 1, amb = .3, sep = GRAN[1], rim = true })
local big = c:ellipse(17, 23.5, 10, 7.5)
big:cut(c:rect(0, 31, 35, 35))
local bb = {} big:each(function(x, y) if y >= 30 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, big, GRAN, { R = 4, bias = bb, amb = .22, wrap = .35, sep = GRAN[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, GRAN, function(x, y, i)
  if x > 10 and x < 24 and y > 18 and y < 27 then return nil end
  local h = H(x, y, 21)
  if h > .9 and i >= 2 and i <= 5 then return 1 end
end)
O.mark(c, { { 23, 28 }, { 24, 27 }, { 25, 26 }, { 26, 25 } }, GRAN[2]) O.mark(c, { { 23, 27 }, { 24, 26 }, { 25, 25 } }, GRAN[4])
O.mark(c, { { 9, 26 }, { 10, 26 } }, LICH[2]) O.mark(c, { { 22, 18 } }, LICH[3])

local top = c:ellipse(15, 12.5, 6, 4)
local tb = {} top:each(function(x, y) if y >= 15 then tb[K(x, y)] = -1 end end)
O.shade(c, top, GRAN, { R = 2, bias = tb, amb = .25, wrap = .35, sep = GRAN[1], rim = true, bounce = BNC, bmax = 2 })

O.mark(c, { { 11, 18 }, { 12, 18 }, { 13, 18 }, { 19, 18 }, { 20, 18 }, { 21, 18 } }, GRAN[6])
O.mark(c, { { 12, 19 }, { 13, 19 }, { 19, 19 }, { 20, 19 } }, GRAN[2])
c:eyeSmall(12, 20) c:eyeSmall(19, 20)
O.dot(c, 10, 24, "#f5809f") O.dot(c, 23, 24, "#f5809f")
O.mark(c, { { 14, 25 }, { 15, 25 }, { 16, 25 }, { 17, 25 }, { 18, 25 } }, P.ink)

-- agama on the top boulder
O.flat(c, c:rect(13, 8, 18, 8), LIZ[3], "liz") O.dots(c, { { 14, 8 }, { 16, 8 } }, LIZ[4])
O.flat(c, c:line({ { 19, 8 }, { 21, 9 }, { 22, 11 } }, 1), LIZ[2], "liz")
O.flat(c, c:rect(10, 7, 12, 8), LHD[2], "lhead") O.dot(c, 10, 7, LHD[3]) O.dot(c, 11, 7, P.ink)
O.dots(c, { { 14, 9 }, { 17, 9 } }, LIZ[1])

O.shift(c, 1, 0)
O.done(c, "th-kopje-keeper-perch")
