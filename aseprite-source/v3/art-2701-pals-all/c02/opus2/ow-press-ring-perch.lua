-- Press Ring (ow-press-ring), perch sprite 36x36. Opus second pass (c02/opus2), hand-built at this size.
-- Upright granite millstone with the hole set high, two round nubs on top (double knob), an oak press lever
-- through the hole and out to the upper right, face on the heavy lower rim.
-- Fix vs Haiku: the lever was faint against the stone (now a 3 px warm oak beam with a dark seam) and the
-- drip was one pixel (now a 2 px gold run ending in a hanging drop, plus a gold puddle).
-- quirk: golden oil dripping from its lower lip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-press-ring-perch", 36)

local STN  = { "#2e2834", "#4a4048", "#685c5e", "#8a7c76", "#ac9e90", "#cec2ac" }
local WOOD = { "#3e2420", "#62382a", "#8a5434", "#b07642", "#d29a5a", "#ecc184" }
local OIL  = { "#8a5a10", "#c08a18", "#e8b420", "#f8d84a", "#fff2a0" }

c:groundShadow(17, 31, 11, 1.2)
O.flat(c, c:rect(20, 32, 24, 32), OIL[3], "puddle") O.dot(c, 21, 32, OIL[5]) O.dot(c, 24, 32, OIL[2])

local lev = c:line({ { 15, 15 }, { 31, 4 } }, 2.5)
O.shade(c, lev, WOOD, { R = 1, amb = .3, wrap = .35, sep = WOOD[1] })
local ring = c:ellipse(17, 18, 11, 10.5)
ring:cut(c:ellipse(17, 14.5, 4, 3.5))
for _, kx in ipairs({ 11, 23 }) do O.shade(c, c:ellipse(kx, 8, 2, 2), STN, { R = 1, amb = .3, rim = true }) end
local rb = {}
ring:each(function(x, y) rb[K(x, y)] = -1 if y > 26 then rb[K(x, y)] = -2 end end)
local sI, sT = O.shade(c, ring, STN, { R = 3, bias = rb, amb = .22, wrap = .35, rim = true, sep = STN[2] })
O.tex(c, sI, sT, STN, function(x, y, i) if H(x, y, 12) > .95 and i >= 2 and i <= 4 then return 1 end end)

c:eyeSmall(12, 21)
c:eyeSmall(21, 21)
O.dot(c, 10, 24, "#f5809f") O.dot(c, 25, 24, "#f5809f")
O.dots(c, { { 15, 25 }, { 16, 26 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)
-- oil run + hanging drop
O.flat(c, c:rect(17, 27, 17, 27), OIL[3], "oil")
O.flat(c, c:rect(17, 28, 18, 29), OIL[3], "drop") O.dot(c, 17, 28, OIL[5]) O.dot(c, 18, 29, OIL[2])

O.done(c, "ow-press-ring-perch")
