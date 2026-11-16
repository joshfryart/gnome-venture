-- Yam Nub (gc-yam-nub), perch sprite 36x36. Opus second pass (c04/opus2), hand-built at this size:
-- the knobbly mauve-brown tuber (three knobs, two eye-pits, two root hairs) half out of a cool soil mound,
-- a sprout with two leaves, the face mid-giggle (2x3 pills, open laughing mouth with a red tongue, cheeks).
-- quirk: the little trowel stuck in the soil beside it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gc-yam-nub-perch", 36)

local YAM  = { "#3a1e2a", "#5e3238", "#864a44", "#a86a52", "#c99070", "#e3b896" }
local SOIL = { "#231c26", "#3a2e36", "#54443e", "#6e5a4e", "#8a7460" }
local LEAF = { "#173a2c", "#1f5a3a", "#2f7a3e", "#4f9e46", "#82c25a", "#bde28a" }
local IRON = { "#4d4f67", "#8d8fa5", "#d2d2dc" }

-- trowel
O.flat(c, c:rect(29, 15, 30, 20), "#8a5a2a", "handle") O.dot(c, 29, 15, "#b07e38")
O.flat(c, c:rect(28, 21, 31, 25), IRON[2], "blade") O.dots(c, { { 28, 21 }, { 28, 22 } }, IRON[3]) O.dots(c, { { 31, 23 }, { 31, 24 } }, IRON[1])

local tub = O.unionCircles{ { 17, 21, 9.5, 8 }, { 10, 17, 3.5, 3.5 }, { 15, 13.5, 3.5, 3 }, { 22, 14.5, 3.5, 3 }, { 25, 22, 3, 3 } }
O.shade(c, tub, YAM, { R = 4, amb = .06, wrap = .25, rim = true, bounce = "#7a6a9a", bmax = 2 })
O.mark(c, { { 11, 15 }, { 23, 13 } }, YAM[2]) O.mark(c, { { 10, 14 }, { 22, 12 } }, YAM[6])
O.dots(c, { { 6, 19 }, { 5, 18 }, { 27, 17 }, { 28, 16 } }, YAM[2])

O.flat(c, c:rect(18, 8, 18, 10), LEAF[3], "vine")
O.shade(c, c:ellipse(15.5, 7, 2.5, 1.6), LEAF, { R = 1, amb = .3, sep = LEAF[1] })
O.shade(c, c:ellipse(20.5, 6, 2.5, 1.6), LEAF, { R = 1, amb = .3, sep = LEAF[1] })

local mound = c:ellipse(17, 31, 15, 3.5)
mound:cut(c:rect(0, 34, 40, 40))
O.shade(c, mound, SOIL, { R = 2, amb = .2, wrap = .4, sep = SOIL[1], cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 9, 29 }, { 22, 29 } }, SOIL[5])

c:eyeSmall(13, 18)
c:eyeSmall(20, 18)
O.dot(c, 10, 22, "#f5809f") O.dot(c, 24, 22, "#f5809f")
O.dots(c, { { 15, 22 }, { 16, 22 }, { 17, 22 }, { 18, 22 }, { 19, 22 }, { 15, 23 }, { 19, 23 }, { 16, 24 }, { 17, 24 }, { 18, 24 } }, P.ink)
O.dots(c, { { 16, 23 }, { 17, 23 }, { 18, 23 } }, "#e86a6a")

O.shift(c, 0, 0)
O.done(c, "gc-yam-nub-perch", function(c) c:put(4, 12, "#f5d0a0") c:put(5, 11, "#f5d0a0") c:put(29, 10, "#f5d0a0") c:put(30, 11, "#f5d0a0") end)
