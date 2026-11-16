-- Nightglow Fleck (pl-owl-2), perch sprite 36x36. Hand-built at this size.
-- quirk: a cream glint sits by the fleck.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-2-perch", 36)

local MOON = { "#3c4a6e", "#5e6e96", "#8c9cc0", "#b8c6e0", "#dce6f4", "#f2f6fc" }

local disc = c:ellipse(18, 18, 11, 11)
O.shade(c, disc, MOON, { sphere = { 16, 16, 11 }, amb = .18, wrap = .3, sep = MOON[1] })
O.flat(c, c:ellipse(24, 24, 1, 1), MOON[3], "crater")

local hook = c:line({ { 18, 7 }, { 18, 4 }, { 21, 3 } }, 1)
O.shade(c, hook, MOON, { R = 1, amb = .3, sep = MOON[1] })

c:eyeSmall(14, 16) c:eyeSmall(20, 16)
O.dots(c, { { 17, 21 }, { 18, 21 } }, P.ink)

c:sparkle(31, 5)

O.done(c, "pl-owl-2-perch")
