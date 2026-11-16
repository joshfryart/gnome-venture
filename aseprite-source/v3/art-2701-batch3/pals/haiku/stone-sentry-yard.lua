-- Stone Sentry (mm-stone-sentry), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Rootwarden, uncommon. A stout grey boulder with a flat top, a moss tuft and stubby arms.
-- quirk: a ladybird resting on its head, which it insists is part of the rock.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("stone-sentry-yard", 64)

local STONE = { "#444663", "#5a5b78", "#74758c", "#aaa9b8", "#c9c8d3", "#e2e0e6" }
local MOSS  = { "#24544a", "#2f7150", "#3f9150", "#7cc35a", "#c4e07a" }
local EMBER = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(32, 58, 19, 3)

-- stubby arms
O.shade(c, c:ellipse(11, 48, 3, 2.5), STONE, { R = 1, amb = .3, sep = STONE[1] })
O.shade(c, c:ellipse(53, 48, 3, 2.5), STONE, { R = 1, amb = .3, sep = STONE[1] })

-- boulder: flat top, flat base
local rock = c:ellipse(32, 38, 20, 16)
rock:cut(c:rect(0, 0, 63, 19))
rock:cut(c:rect(0, 54, 63, 63))
O.shade(c, rock, STONE, { R = 7, amb = .2, wrap = .3, sep = STONE[1] })
O.mark(c, { { 20, 30 }, { 21, 31 }, { 22, 32 }, { 22, 33 } }, STONE[1]) -- cracks
O.mark(c, { { 42, 44 }, { 43, 45 }, { 43, 46 } }, STONE[1])
O.mark(c, { { 34, 50 }, { 35, 49 } }, STONE[1])

-- moss tuft on top
local moss = c:ellipse(31, 21, 13, 4)
moss:cut(c:rect(0, 25, 63, 63))
O.shade(c, moss, MOSS, { R = 2, amb = .2, sep = MOSS[1] })

-- quirk: ladybird on the head
O.shade(c, c:ellipse(45, 25, 2.5, 2), EMBER, { R = 1, amb = .3, sep = EMBER[1] })
O.dot(c, 45, 25, P.ink)
O.dot(c, 44, 24, EMBER[4])

-- face: locked eyes, designed nose, petal cheeks, flat mouth
c:eyeLocked(20, 33)
c:eyeLocked(38, 33)
c:cheek(18, 40) c:cheek(44, 40)
O.dots(c, { { 31, 39 }, { 32, 39 }, { 31, 40 }, { 32, 40 } }, STONE[1])
O.dots(c, { { 29, 44 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 44 } }, P.ink)

O.done(c, "stone-sentry-yard")
