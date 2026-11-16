-- Kapok Nook (rr-kapok-nook), perch sprite 36x36. Opus richness pass (opus3), hand-built at this size:
-- fluff as five puffs with a rim light and three strand marks, husk cup with a lit lip and speckles.
-- Fix vs opus2: the full 2x3 pill eyes now show (no lid over them); sleepiness is a dark lid arc above each
-- pill drooping to the outer corner, so the eyes read as eyes at 1x.
-- quirk: the root knuckle with its tiny door and pennant, cut down to a 5x6 door.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("kapok-nook-perch", 36)

local BARK = { "#3a2329", "#5a3530", "#7c4f3a", "#9e6c48", "#bf8d5c", "#dcb27c" }
local HUSK = { "#2f2a1f", "#4c4228", "#6c6033", "#8c7d3f", "#ab9a52", "#c9b874" }
local FLUF = { "#6c5f80", "#9488aa", "#bbb0cb", "#d8d0e2", "#ece6ee", "#faf3ee" }
local DOOR = { "#3d2422", "#5e3a2c", "#7e5236", "#9b6a42" }

c:groundShadow(18, 32, 13, 1.5)

-- root knuckle + tail
local root = c:ellipse(8, 27, 6, 6)
root:add(O.tube({ { 12, 31 }, { 19, 27 }, { 27, 27 }, { 31, 31 } }, function(t) return 2.2 - 1 * t end))
root:cut(c:rect(0, 33, 35, 35))
O.shade(c, root, BARK, { R = 3, amb = .2, wrap = .4, rim = true, bounce = "#6a5060", bmax = 2 })
O.mark(c, { { 4, 25 }, { 4, 26 }, { 5, 23 }, { 22, 28 }, { 23, 28 }, { 28, 29 } }, BARK[3])

-- quirk: door + pennant
local door = c:rect(6, 28, 10, 32)
door:add(c:rect(7, 27, 9, 27))
O.flat(c, door, DOOR[3], "door")
O.dots(c, { { 5, 29 }, { 5, 30 }, { 6, 27 }, { 7, 26 }, { 8, 26 }, { 9, 26 }, { 10, 27 }, { 11, 28 } }, BARK[6])
O.dots(c, { { 8, 28 }, { 8, 29 }, { 8, 30 }, { 8, 31 }, { 8, 32 } }, DOOR[2])
O.dots(c, { { 10, 29 }, { 10, 30 }, { 10, 31 }, { 10, 32 } }, DOOR[1])
O.dot(c, 9, 30, "#ffe38a")
O.dots(c, { { 10, 23 }, { 11, 23 } }, "#f5b82e") O.dot(c, 10, 23, "#ffe38a") -- lit window
O.flat(c, c:rect(5, 15, 5, 21), DOOR[4], "pole")
O.flat(c, c:poly{ { 6, 15 }, { 10, 16 }, { 6, 17 } }, "#e8493b", "flag")
O.dot(c, 6, 15, "#ff8a5c") O.dot(c, 6, 17, "#b52e3f") O.dot(c, 5, 14, "#f5b82e")

-- fluff
local fl = O.unionCircles{ { 21, 18, 8.5, 6.5 }, { 15, 15, 3.5 }, { 19, 11, 3.5 }, { 24, 11, 3.5 }, { 28, 15, 3.5 } }
O.shade(c, fl, FLUF, { R = 4, amb = .3, wrap = .45, rim = true })
O.mark(c, { { 20, 10 }, { 21, 9 }, { 27, 13 }, { 28, 14 }, { 13, 16 }, { 14, 17 } }, FLUF[3])
O.dots(c, { { 26, 11 }, { 27, 11 } }, "#3b2f36") -- a kapok seed

-- husk cup
local husk = c:ellipse(21, 24, 10, 4.5)
husk:cut(c:rect(0, 0, 35, 21))
husk:add(c:poly{ { 10, 19 }, { 13, 22 }, { 12, 25 } })
husk:add(c:poly{ { 32, 19 }, { 29, 22 }, { 30, 25 } })
local hb = {}
husk:each(function(x, y) if y == 22 then hb[K(x, y)] = 1 end if x == 21 and y > 23 then hb[K(x, y)] = -2 end end)
O.shade(c, husk, HUSK, { R = 2, bias = hb, amb = .18, wrap = .3, sep = HUSK[1], rim = true, bounce = "#5c6a5a", bmax = 2 })
O.mark(c, { { 15, 24 }, { 26, 25 }, { 18, 26 } }, HUSK[5]) -- lenticels

-- sleepy face
for i, ex in ipairs({ 17, 24 }) do
  c:eyeSmall(ex, 16)
  -- sleepy lid arc above the pill, drooping to the outer corner
  O.dots(c, { { ex, 15 }, { ex + 1, 15 } }, FLUF[1])
  O.dot(c, i == 1 and ex - 1 or ex + 2, 16, FLUF[1])
end
O.dots(c, { { 15, 20 } }, "#f5809f") O.dots(c, { { 28, 20 } }, "#f5809f")
O.dot(c, 21, 19, "#a07a9a") O.dot(c, 21, 20, "#6c4a68")
O.dots(c, { { 21, 21 } }, "#6e2c4a")

O.done(c, "kapok-nook-perch")
