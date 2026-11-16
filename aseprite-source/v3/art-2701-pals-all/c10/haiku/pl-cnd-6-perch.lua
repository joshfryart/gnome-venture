-- Grand Condor Plume (pl-cnd-6), perch sprite 36x36. Hand-built at this size.
-- quirk: wind dashes trail off the left side, it still floats.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-cnd-6-perch", 36)

local FEA  = { "#3a2220", "#6a3e2c", "#9a6440", "#c48a58", "#e0b488", "#f4dcb8" }
local GOLD = { "#6b4a10", "#a8761c", "#d9a53a", "#f5d27a" }
local SKY  = { "#5f9ad0", "#8bc4ea" }

local vane = c:poly{ { 24, 3 }, { 30, 6 }, { 32, 12 }, { 30, 19 }, { 24, 26 }, { 16, 32 }, { 10, 34 }, { 9, 29 }, { 14, 20 }, { 19, 11 } }
O.shade(c, vane, FEA, { R = 2, amb = .2, wrap = .3, sep = FEA[1] })
local barbs = {}
vane:each(function(x, y) if (x + 2 * y) % 7 == 0 then barbs[#barbs + 1] = { x, y } end end)
O.mark(c, barbs, FEA[2])
local trim = vane:edge()
trim:cut(c:rect(0, 20, 35, 35))
O.flat(c, trim, GOLD[3], "trim")

local quill = c:line({ { 26, 1 }, { 14, 33 } }, 1)
O.shade(c, quill, GOLD, { R = 1, amb = .3, sep = GOLD[1] })

O.flat(c, c:line({ { 1, 26 }, { 5, 26 } }, 1), SKY[2], "wind")
O.flat(c, c:line({ { 2, 31 }, { 5, 31 } }, 1), SKY[2], "wind")

c:eyeSmall(19, 13) c:eyeSmall(23, 13)
O.dots(c, { { 20, 19 }, { 21, 19 } }, P.ink)
c:sparkle(5, 8)

O.done(c, "pl-cnd-6-perch")
