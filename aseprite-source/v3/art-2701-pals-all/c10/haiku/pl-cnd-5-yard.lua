-- Nest Wobble (pl-cnd-5), yard sprite 64x64. Bloomcaller, uncommon. Twiggy nest with an egg face on a cloud.
-- quirk: a loose twig hangs off the cloud edge and swings with the wind.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-cnd-5-yard", 64)

local CLD  = { "#6f86ae", "#9aafd0", "#bccbe4", "#d6e0f0", "#e8eef8", "#f4f8fc" }
local TWIG = { "#3a2220", "#5e3628", "#865234", "#a8703f", "#c99254", "#e3b676" }
local EGG  = { "#7a6080", "#a48aa8", "#c8b4d0", "#e2d4e8", "#f2eaf6", "#fbf8fc" }

-- cloud
local cloud = c:ellipse(20, 52, 9, 6)
cloud:add(c:ellipse(32, 47, 12, 9))
cloud:add(c:ellipse(45, 52, 9, 6))
cloud:cut(c:rect(0, 57, 63, 63))
O.shade(c, cloud, CLD, { R = 3, amb = .25, wrap = .3 })

-- back ring of the nest
local ring = c:ellipse(32, 38, 20, 9)
ring:cut(c:ellipse(32, 36, 14, 4))
O.shade(c, ring, TWIG, { R = 2, amb = .25, sep = TWIG[1] })
local flecks = {}
ring:each(function(x, y) if O.H(x, y, 3) > .75 then flecks[#flecks + 1] = { x, y } end end)
O.mark(c, flecks, TWIG[2])

-- egg with face, sitting in the nest
local egg = c:ellipse(32, 31, 10, 10)
egg:cut(c:rect(0, 40, 63, 63))
O.shade(c, egg, EGG, { sphere = { 29, 27, 10 }, amb = .2, wrap = .3, sep = EGG[1] })

-- front lip of the nest over the egg bottom
local front = ring:copy()
front:cut(c:rect(0, 0, 63, 36))
O.shade(c, front, TWIG, { R = 2, amb = .25, sep = TWIG[1] })

-- hook knob: a curled twig on top
local hook = c:line({ { 32, 22 }, { 32, 14 }, { 38, 11 } }, 1.6)
O.shade(c, hook, TWIG, { R = 1, amb = .3 })
-- quirk: a loose twig swinging off the cloud
local swing = c:line({ { 48, 40 }, { 52, 46 }, { 50, 53 } }, 1.4)
O.shade(c, swing, TWIG, { R = 1, amb = .3, sep = TWIG[1] })

c:eyeLocked(25, 27)
c:eyeLocked(35, 27)
c:cheek(22, 33) c:cheek(38, 33)
O.dots(c, { { 31, 34 }, { 32, 35 }, { 33, 34 } }, P.ink)

O.done(c, "pl-cnd-5-yard")
