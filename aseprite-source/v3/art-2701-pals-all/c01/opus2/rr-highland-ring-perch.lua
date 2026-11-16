-- Highland Ring (rr-highland-ring), perch sprite 36x36. Opus second pass (c01/opus2), hand-built at this size.
-- Granite hoop with an open hole, scalloped snow cap and two icicles, a 3-bump cloud puff in the hole,
-- the face on the thick lower band (pill eyes, raised brows, smug smile), two heather sprigs.
-- quirk: the summit flag on top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("rr-highland-ring-perch", 36)

local STN  = { "#2c3048", "#434a68", "#5f6888", "#8590ac", "#aeb8cc", "#d0d8e4" }
local SNOW = { "#6a78a0", "#98a6c6", "#c4d0e4", "#e2eaf4", "#f2f6fa" }
local HEA  = { "#6a3a78", "#c47cc0", "#e4aadc" }
local CLD  = { "#8696b4", "#b2c0d6", "#d9e3ee", "#eef3f8" }

c:groundShadow(18, 32, 11, 1.5)
local outer = c:ellipse(18, 19.5, 10.5, 12)
local hole = c:ellipse(18, 15.5, 5, 5.5)
local ring = outer:copy():cut(hole)
local rb = {}
ring:each(function(x, y) if hole:has(x, y - 1) then rb[K(x, y)] = -1 end end)
local rI, rT = O.shade(c, ring, STN, { R = 4, bias = rb, amb = .1, wrap = .3, sep = STN[1], rim = true, bounce = "#7a8ab8", bmax = 2 })
O.tex(c, rI, rT, STN, function(x, y, i) if y < 21 and H(x, y, 13) > .9 and i >= 2 and i <= 5 then return 1 end end)
-- a wisp of cloud along the bottom of the hole (the hole stays open above it)
local cl = O.unionCircles{ { 17, 20, 2.5, 1.2 }, { 20, 19.5, 1.5, 1.2 } }
cl:clip(hole)
O.shade(c, cl, CLD, { R = 1, amb = .4, cuts = { .35, .6, .85 } })
local snow = HP.mask()
outer:each(function(x, y)
  local hem = 11 + ((x % 3 == 0) and 1 or 0) + ((x < 13 or x > 23) and 2 or 0)
  if y <= hem then snow:set(x, y) end
end)
snow:cut(hole)
O.shade(c, snow, SNOW, { R = 2, amb = .3, wrap = .4, sep = SNOW[1], cuts = { .25, .5, .72, .88 }, rim = true })
O.dots(c, { { 16, 10 }, { 16, 11 }, { 20, 10 } }, SNOW[3]) O.dot(c, 16, 12, SNOW[2])
-- flag
O.seg(c, 18, 7, 18, 4, "#86563a")
O.dots(c, { { 19, 4 }, { 20, 4 }, { 21, 4 }, { 19, 5 }, { 20, 5 } }, "#d23a3a") O.dot(c, 19, 4, "#f06a4a") O.dot(c, 21, 5, "#7c1c34")
-- heather
for _, t in ipairs({ { 8, 29 }, { 28, 29 } }) do
  O.dots(c, { { t[1], t[2] + 1 }, { t[1] + 1, t[2] + 1 } }, "#2f6b46") O.dot(c, t[1], t[2], HEA[2]) O.dot(c, t[1] + 1, t[2] - 1, HEA[3]) O.dot(c, t[1] + 1, t[2], HEA[1])
end
-- face
c:eyeSmall(13, 24)
c:eyeSmall(21, 24)
O.dots(c, { { 12, 23 }, { 13, 22 }, { 14, 22 } }, STN[1]) O.dots(c, { { 21, 22 }, { 22, 22 }, { 23, 23 } }, STN[1])
O.dots(c, { { 16, 28 }, { 17, 28 }, { 18, 28 }, { 19, 27 } }, P.ink)
O.dot(c, 11, 27, P.petal.base) O.dot(c, 24, 27, P.petal.base)
O.done(c, "rr-highland-ring-perch")
