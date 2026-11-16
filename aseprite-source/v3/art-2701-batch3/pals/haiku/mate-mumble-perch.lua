-- Mate Mumble (rr-mate-mumble), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: a hum of notes over the straw, here three sky dots.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mate-mumble-perch", 36)

local GOURD = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e" }
local STONE = { "#74758c", "#aaa9b8", "#c9c8d3" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

c:groundShadow(16, 31, 10, 2)

local g = c:ellipse(18, 22, 9, 8)
g:add(c:ellipse(16, 12, 5, 5))
O.shade(c, g, GOURD, { sphere = { 15, 18, 9 }, amb = .15, wrap = .3, sep = GOURD[1] })
O.dots(c, { { 10, 17 }, { 11, 17 }, { 12, 17 }, { 13, 17 }, { 22, 17 }, { 23, 17 }, { 24, 17 }, { 25, 17 } }, GOLD[3])
O.dots(c, { { 10, 18 }, { 24, 18 } }, GOLD[2])

local straw = c:line({ { 25, 19 }, { 29, 8 } }, 1.2)
O.shade(c, straw, STONE, { R = 1, amb = .3, sep = STONE[1] })

c:eyeSmall(12, 20)
c:eyeSmall(20, 20)
O.dots(c, { { 16, 25 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)

O.dots(c, { { 31, 4 }, { 32, 3 }, { 33, 3 } }, SKY[2]) -- quirk: notes

O.done(c, "mate-mumble-perch")
