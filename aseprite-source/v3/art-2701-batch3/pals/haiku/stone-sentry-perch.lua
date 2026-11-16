-- Stone Sentry (mm-stone-sentry), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: the ladybird on its head, here a 2x2 ember dot.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("stone-sentry-perch", 36)

local STONE = { "#444663", "#5a5b78", "#74758c", "#aaa9b8", "#c9c8d3" }
local MOSS  = { "#24544a", "#3f9150", "#7cc35a" }
local EMBER = { "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(18, 31, 11, 2)

local rock = c:ellipse(18, 19, 12, 11)
rock:cut(c:rect(0, 0, 35, 8))
rock:cut(c:rect(0, 30, 35, 35))
O.shade(c, rock, STONE, { R = 3, amb = .2, wrap = .3, sep = STONE[1] })
O.mark(c, { { 11, 16 }, { 12, 17 } }, STONE[1])

local moss = c:ellipse(16, 9, 6, 2)
moss:cut(c:rect(0, 11, 35, 35))
O.shade(c, moss, MOSS, { R = 1, amb = .2, sep = MOSS[1] })

O.shade(c, c:ellipse(27, 12, 2, 2), EMBER, { R = 1, amb = .3, sep = EMBER[1] })
O.dot(c, 27, 12, P.ink)

c:eyeSmall(12, 17)
c:eyeSmall(21, 17)
O.dots(c, { { 15, 23 }, { 16, 24 }, { 17, 24 }, { 18, 23 } }, P.ink)

O.done(c, "stone-sentry-perch")
