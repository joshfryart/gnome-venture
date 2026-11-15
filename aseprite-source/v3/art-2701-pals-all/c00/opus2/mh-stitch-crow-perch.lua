-- Stitch Crow (mh-stitch-crow), perch sprite 36x36. Opus second pass (c00/opus2), hand-built at this size.
-- Crow-black body and head (big enough to hold the face), a level straw hat kept smaller than the Haiku one so it
-- no longer dominates, gold beak, 2x3 pill eyes under a flat lid line (serious).
-- quirk: the cream measuring tape round its neck.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-stitch-crow-perch", 36)

local CROW = { "#17121f", "#241d32", "#342c48", "#4a4566", "#686a8e", "#9399bc" }
local STRW = { "#7a4a1f", "#a8702a", "#d49a3a", "#ecc05a", "#f8dc86", "#fff0b4" }
local BAND = { "#5a1a30", "#8a2438", "#c43a3e", "#ee6248" }
local BEAK = { "#7a3a1a", "#c27022", "#f5b82e", "#ffe38a" }
local TAPE = { "#a89070", "#d8c8a0", "#f4ead0" }
local FEET = { "#8f4a1f", "#d98322", "#f5a83a" }

c:groundShadow(18, 32, 9, 1)
-- tail
local tail, tn = O.tube({ { 11, 25 }, { 8, 27 }, { 6, 29 }, { 4, 31 } }, function(t) return 2.2 - t end)
O.shadeN(c, tail, tn, CROW, { amb = .3, wrap = .4, rim = true })
for _, fx in ipairs({ 15, 20 }) do
  O.flat(c, c:rect(fx, 29, fx, 31), FEET[2], "leg") O.flat(c, c:rect(fx - 1, 31, fx + 1, 31), FEET[2], "toe")
end
O.shade(c, c:ellipse(18, 24, 8, 6.5), CROW, { sphere = { 15, 20, 10 }, amb = .22, wrap = .35, rim = true, bounce = "#4a5a7a", bmax = 2 })
O.shade(c, c:ellipse(18, 15, 7, 6), CROW, { sphere = { 15, 12, 8 }, amb = .28, wrap = .38, rim = true })
-- wing
local wing, wn = O.tube({ { 12, 19 }, { 10, 22 }, { 10, 26 }, { 13, 28 } }, function(t) return 3 - t end)
O.shadeN(c, wing, wn, CROW, { amb = .3, wrap = .4, sep = CROW[1] })
-- tape
local tape = HP.mask()
for x = 12, 24 do local y = 20 + ((math.abs(x - 18) <= 3) and 1 or 0) tape:add(c:rect(x, y, x, y)) end
tape:add(c:rect(22, 21, 22, 26))
O.flat(c, tape, TAPE[2], "tape")
O.dots(c, { { 14, 20 }, { 17, 21 }, { 20, 21 }, { 22, 23 }, { 22, 25 } }, P.ink)
O.dots(c, { { 12, 20 }, { 13, 20 } }, TAPE[3])
-- beak
O.shade(c, c:poly{ { 23, 14 }, { 30, 16.5 }, { 23, 19 } }, BEAK, { R = 1, amb = .4, cuts = { .3, .6, .8 }, sep = CROW[1] })
O.dots(c, { { 24, 17 }, { 25, 17 }, { 26, 17 }, { 27, 17 } }, BEAK[1])
-- hat
local crown = c:rrect(12, 2, 24, 9, 2)
local cI, cT = O.shade(c, crown, STRW, { R = 2, amb = .3, wrap = .4, rim = true })
O.tex(c, cI, cT, STRW, function(x, y, i) if (x + y) % 3 == 0 then return -1 end end)
O.shade(c, c:rect(12, 8, 24, 9), BAND, { R = 1, amb = .4, cuts = { .3, .6, .82 } })
local brim = c:ellipse(18, 10.5, 12, 1.5)
local rI, rT = O.shade(c, brim, STRW, { R = 1, amb = .4, wrap = .4, sep = STRW[2] })
-- face: serious pill eyes with a flat lid
-- pale eye rings so the ink pills read on crow-black; flat top edge = stern lid
for _, ex in ipairs({ 14, 20 }) do
  O.flat(c, c:rect(ex - 1, 13, ex + 2, 16), "#c3c6dc", "ring")
  O.dots(c, { { ex - 1, 16 }, { ex + 2, 16 } }, CROW[4])
  O.dots(c, { { ex - 1, 12 }, { ex, 12 }, { ex + 1, 12 }, { ex + 2, 12 } }, CROW[2])
end
c:eyeSmall(14, 13)
c:eyeSmall(20, 13)

O.shift(c, 0, 0)
O.done(c, "mh-stitch-crow-perch")
