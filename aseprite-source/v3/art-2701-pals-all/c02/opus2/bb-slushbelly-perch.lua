-- Slushbelly (bb-slushbelly), perch sprite 36x36. Opus second pass (c02/opus2), hand-built at this size.
-- Icy slush blob slumping into a meltwater puddle, snowball knob (round) with a dark sunflower seed in it,
-- shy sideways pill eyes, worried brows, wobbly mouth.
-- Fix vs Haiku: the eye-drip vanished at small size; now a drip bulges out of its side and a drop falls,
-- both outlined so they carry at 36 px; paler, less noisy slush.
-- quirk: melting because you are looking (side drip + falling drop).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-slushbelly-perch", 36)

local SL   = { "#3e5a98", "#5a82c0", "#7ea8dc", "#a6caec", "#cae2f4", "#e6f2f8" }
local SNOW = { "#5e6c98", "#8a9cc0", "#b4c4da", "#d6e2ec", "#ecf2f4" }
local PUD  = { "#24587a", "#3a7ea2", "#5aa6c2", "#8acad8", "#bce6ea" }

local pud = c:ellipse(17, 30, 14, 2.2)
O.shade(c, pud, PUD, { R = 1.5, amb = .35, wrap = .4, cuts = { .25, .45, .65, .84 } })

local body = c:ellipse(17, 20, 9, 8.5)
body:add(c:poly{ { 8, 23 }, { 26, 23 }, { 29, 29 }, { 5, 29 } })
body:add(c:ellipse(27.5, 25, 1.5, 2)) body:add(c:rect(27, 22, 28, 24))
local bb = {}
body:each(function(x, y) if y > 27 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, SL, { sphere = { 13, 15, 13 }, bias = bb, amb = .3, wrap = .4, rim = true, sep = SL[1] })
O.tex(c, bI, bT, SL, function(x, y, i) if H(x, y, 7) > .95 and i <= 5 then return 1 end end)
O.dots(c, { { 11, 14 }, { 12, 14 } }, SL[6])
O.dots(c, { { 27, 23 }, { 27, 24 } }, SL[6])

O.shade(c, c:ellipse(17, 10, 3.5, 3), SNOW, { sphere = { 16, 9, 4 }, amb = .3, sep = SNOW[1], cuts = { .25, .45, .65, .84 } })
O.flat(c, c:rect(19, 7, 21, 8), "#4a4250", "seed") O.dot(c, 20, 7, "#c8c2c4")

-- shy sideways pill eyes + brows
c:eyeSmall(12, 18)
c:eyeSmall(19, 18)
O.dots(c, { { 13, 16 }, { 14, 16 } }, SL[1]) O.dots(c, { { 19, 16 }, { 20, 16 } }, SL[1])
O.dot(c, 10, 22, "#f5809f") O.dot(c, 23, 22, "#f5809f")
O.dots(c, { { 14, 24 }, { 15, 23 }, { 16, 24 }, { 17, 23 }, { 18, 24 }, { 19, 23 } }, P.ink)

-- falling drop
O.flat(c, c:rect(31, 25, 31, 27), SL[4], "drop") O.dot(c, 31, 25, SL[6])

O.shift(c, 0, -2)
O.done(c, "bb-slushbelly-perch")
