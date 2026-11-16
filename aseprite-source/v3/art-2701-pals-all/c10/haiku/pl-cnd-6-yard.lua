-- Grand Condor Plume (pl-cnd-6), yard sprite 64x64. Thornblade, rare. The biggest feather the Grand Condor ever dropped.
-- Fancier than a common pal: gold quill, gold trim on the sunlit edge, sparkles.
-- quirk: it still floats, so wind dashes trail off its left side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-cnd-6-yard", 64)

local FEA  = { "#3a2220", "#6a3e2c", "#9a6440", "#c48a58", "#e0b488", "#f4dcb8" }
local GOLD = { "#6b4a10", "#a8761c", "#d9a53a", "#f5d27a" }
local SKY  = { "#5f9ad0", "#8bc4ea" }

local vane = c:poly{ { 46, 6 }, { 54, 10 }, { 58, 20 }, { 56, 30 }, { 46, 42 }, { 32, 52 }, { 20, 60 }, { 14, 58 }, { 18, 46 }, { 26, 30 }, { 34, 16 }, { 40, 8 } }
O.shade(c, vane, FEA, { R = 4, amb = .2, wrap = .3, sep = FEA[1] })
local barbs = {}
vane:each(function(x, y) if (x + 2 * y) % 9 == 0 then barbs[#barbs + 1] = { x, y } end end)
O.mark(c, barbs, FEA[2])
local trim = vane:edge()
trim:cut(c:rect(0, 31, 63, 63))
trim:cut(c:rect(0, 0, 35, 30))
O.flat(c, trim, GOLD[3], "trim")

local quill = c:line({ { 50, 2 }, { 33, 30 }, { 15, 61 } }, 1.2)
O.shade(c, quill, GOLD, { R = 1, amb = .3, sep = GOLD[1] })

O.flat(c, c:line({ { 2, 46 }, { 8, 46 } }, 1), SKY[2], "wind")
O.flat(c, c:line({ { 4, 52 }, { 9, 52 } }, 1), SKY[2], "wind")
O.flat(c, c:line({ { 1, 58 }, { 6, 58 } }, 1), SKY[2], "wind")

c:eyeLocked(33, 22)
c:eyeLocked(41, 22)
c:cheek(30, 30) c:cheek(44, 30)
O.dots(c, { { 37, 33 }, { 38, 34 }, { 39, 33 } }, P.ink)
c:sparkle(8, 12)
c:sparkle(54, 40)

O.done(c, "pl-cnd-6-yard")
