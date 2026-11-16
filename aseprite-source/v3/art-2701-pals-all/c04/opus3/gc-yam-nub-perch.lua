-- Yam Nub (gc-yam-nub), perch sprite 36x36. Opus richness pass (c04/opus3), hand-built at this size.
-- Richness pass: hue-shifted skin ramp, two bold growth rings on the flanks, pits with a lit lower lip, a pale
-- trowel nick, leaf midribs, a lit clod and a grey pebble in the soil, a little worm head poking out. From opus2:
-- the knobbly mauve-brown tuber (three knobs, two eye-pits, two root hairs) half out of a cool soil mound,
-- a sprout with two leaves, the face mid-giggle (2x3 pills, open laughing mouth with a red tongue, cheeks).
-- quirk: the little trowel stuck in the soil beside it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gc-yam-nub-perch", 36)

local YAM  = { "#361a2e", "#5c2e3c", "#844644", "#a86a52", "#ca926e", "#e6bc94" }
local SOIL = { "#231c26", "#3a2e36", "#54443e", "#6e5a4e", "#8a7460" }
local LEAF = { "#173a2c", "#1f5a3a", "#2f7a3e", "#4f9e46", "#82c25a", "#bde28a" }
local IRON = { "#4d4f67", "#8d8fa5", "#d2d2dc" }

-- trowel
O.flat(c, c:rect(29, 15, 30, 20), "#8a5a2a", "handle") O.dot(c, 29, 15, "#b07e38")
O.flat(c, c:rect(28, 21, 31, 25), IRON[2], "blade") O.dots(c, { { 28, 21 }, { 28, 22 } }, IRON[3]) O.dots(c, { { 31, 23 }, { 31, 24 } }, IRON[1])

local tub = O.unionCircles{ { 17, 21, 9.5, 8 }, { 10, 17, 3.5, 3.5 }, { 15, 13.5, 3.5, 3 }, { 22, 14.5, 3.5, 3 }, { 25, 22, 3, 3 } }
local tI, tT = O.shade(c, tub, YAM, { R = 4, amb = .06, wrap = .25, rim = true, bounce = "#7a6a9a", bmax = 2 })
O.tex(c, tI, tT, YAM, function(x, y, i) -- growth rings on the flanks
  local r = (y - 21) + ((x - 17) / 6) ^ 2
  if (x < 11 or x > 23) and math.floor(r) % 4 == 0 and i >= 3 then return -1 end
end)
O.mark(c, { { 11, 15 }, { 23, 13 } }, YAM[1]) O.mark(c, { { 11, 16 }, { 23, 14 } }, YAM[6])
O.mark(c, { { 25, 21 }, { 25, 22 } }, "#f6ecd2") -- trowel nick
O.dots(c, { { 6, 19 }, { 5, 18 }, { 27, 17 }, { 28, 16 } }, YAM[2])

O.flat(c, c:rect(18, 8, 18, 10), LEAF[3], "vine")
O.shade(c, c:ellipse(15.5, 7, 2.5, 1.6), LEAF, { R = 1, amb = .3, sep = LEAF[1] })
O.shade(c, c:ellipse(20.5, 6, 2.5, 1.6), LEAF, { R = 1, amb = .3, sep = LEAF[1] })
O.mark(c, { { 14, 7 }, { 15, 7 }, { 16, 7 }, { 20, 6 }, { 21, 6 }, { 22, 6 } }, LEAF[3]) -- midribs

local mound = c:ellipse(17, 31, 15, 3.5)
mound:cut(c:rect(0, 34, 40, 40))
O.shade(c, mound, SOIL, { R = 2, amb = .2, wrap = .4, sep = SOIL[1], cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 9, 29 }, { 22, 29 } }, SOIL[5]) O.mark(c, { { 9, 30 }, { 22, 30 } }, SOIL[2])
O.mark(c, { { 14, 31 } }, "#b8b8c0") O.mark(c, { { 15, 31 } }, "#8a8a96") -- pebble
-- worm head poking out
O.flat(c, c:rect(4, 26, 4, 28), "#c8606a", "worm") O.dot(c, 4, 26, "#ec9a98") O.dot(c, 4, 28, "#8a3a4a")

c:eyeSmall(13, 18)
c:eyeSmall(20, 18)
O.dot(c, 10, 22, "#f5809f") O.dot(c, 24, 22, "#f5809f")
O.dots(c, { { 15, 22 }, { 16, 22 }, { 17, 22 }, { 18, 22 }, { 19, 22 }, { 15, 23 }, { 19, 23 }, { 16, 24 }, { 17, 24 }, { 18, 24 } }, P.ink)
O.dots(c, { { 16, 23 }, { 17, 23 }, { 18, 23 } }, "#e86a6a")

O.shift(c, 0, 0)
O.done(c, "gc-yam-nub-perch", function(c) c:put(4, 12, "#f5d0a0") c:put(5, 11, "#f5d0a0") c:put(29, 10, "#f5d0a0") c:put(30, 11, "#f5d0a0") end)
