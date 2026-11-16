-- Nest Wobble (pl-cnd-5), perch sprite 36x36. Hand-built at this size.
-- quirk: a loose twig swings off the cloud edge.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-cnd-5-perch", 36)

local CLD  = { "#6f86ae", "#9aafd0", "#bccbe4", "#d6e0f0", "#e8eef8", "#f4f8fc" }
local TWIG = { "#3a2220", "#5e3628", "#865234", "#a8703f", "#c99254", "#e3b676" }
local EGG  = { "#7a6080", "#a48aa8", "#c8b4d0", "#e2d4e8", "#f2eaf6", "#fbf8fc" }

local cloud = c:ellipse(11, 30, 5, 3)
cloud:add(c:ellipse(18, 27, 6, 5))
cloud:add(c:ellipse(25, 30, 5, 3))
cloud:cut(c:rect(0, 33, 35, 35))
O.shade(c, cloud, CLD, { R = 2, amb = .25, wrap = .3 })

local ring = c:ellipse(18, 23, 11, 5)
ring:cut(c:ellipse(18, 22, 7, 2))
O.shade(c, ring, TWIG, { R = 1, amb = .25, sep = TWIG[1] })

local egg = c:ellipse(18, 17, 6, 6)
egg:cut(c:rect(0, 23, 35, 35))
O.shade(c, egg, EGG, { sphere = { 16, 15, 6 }, amb = .2, wrap = .3, sep = EGG[1] })

local front = ring:copy()
front:cut(c:rect(0, 0, 35, 22))
O.shade(c, front, TWIG, { R = 1, amb = .25, sep = TWIG[1] })

local hook = c:line({ { 18, 11 }, { 18, 7 }, { 21, 6 } }, 1.2)
O.shade(c, hook, TWIG, { R = 1, amb = .3 })
local swing = c:line({ { 30, 24 }, { 32, 28 }, { 31, 32 } }, 1.2)
O.shade(c, swing, TWIG, { R = 1, amb = .3, sep = TWIG[1] })

c:eyeSmall(15, 16) c:eyeSmall(19, 16)
O.dots(c, { { 17, 19 }, { 18, 19 } }, P.ink)

O.done(c, "pl-cnd-5-perch")
