-- Nightglow Fleck (pl-owl-2), yard sprite 64x64. Wayfinder, common. A fleck of moon the owl dropped on the way home.
-- quirk: two cream glints hang off the fleck like it is still glowing.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-2-yard", 64)

local MOON = { "#3c4a6e", "#5e6e96", "#8c9cc0", "#b8c6e0", "#dce6f4", "#f2f6fc" }

local disc = c:ellipse(32, 32, 20, 20)
O.shade(c, disc, MOON, { sphere = { 27, 27, 20 }, amb = .18, wrap = .3, sep = MOON[1] })
O.flat(c, c:ellipse(44, 44, 3, 3), MOON[3], "crater")
O.flat(c, c:ellipse(20, 44, 2, 2), MOON[3], "crater")
O.flat(c, c:ellipse(42, 20, 2, 2), MOON[3], "crater")

local hook = c:line({ { 32, 12 }, { 32, 6 }, { 38, 4 } }, 1.4)
O.shade(c, hook, MOON, { R = 1, amb = .3, sep = MOON[1] })

c:eyeLocked(24, 28)
c:eyeLocked(36, 28)
c:cheek(21, 36) c:cheek(39, 36)
O.dots(c, { { 30, 37 }, { 31, 38 }, { 32, 38 }, { 33, 37 } }, P.ink)

c:sparkle(54, 10)
c:sparkle(8, 50)

O.done(c, "pl-owl-2-yard")
