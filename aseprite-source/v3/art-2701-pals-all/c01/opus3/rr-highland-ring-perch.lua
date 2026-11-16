-- Highland Ring (rr-highland-ring), perch sprite 36x36. Opus third pass (c01/opus3), richness pass over opus2.
-- Fix: the snow cap squared off the top of the hole. The hole is now a taller rounded arch fully ringed by stone
-- (dark inner arch on top, a lit sill at the bottom), and the snow sits above it with drips only on the outer
-- shoulders. Richness: warm violet-grey granite apart from the cool snow, a few feldspar flecks, a lichen dot,
-- a blue shadow under the snow hem, one snow sparkle.
-- Granite hoop with an open hole, scalloped snow cap and two icicles, a 3-bump cloud puff in the hole,
-- the face on the thick lower band (pill eyes, raised brows, smug smile), two heather sprigs.
-- quirk: the summit flag on top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("rr-highland-ring-perch", 36)

local STN  = { "#2a2838", "#463f5a", "#645c78", "#8a8298", "#b0a8b8", "#d4ccd4" }
local SNOW = { "#6a78a0", "#98a6c6", "#c4d0e4", "#e2eaf4", "#f2f6fa" }
local HEA  = { "#6a3a78", "#c47cc0", "#e4aadc" }
local CLD  = { "#8696b4", "#b2c0d6", "#d9e3ee", "#eef3f8" }

c:groundShadow(18, 32, 11, 1.5)
local outer = c:ellipse(18, 19.5, 10.5, 12)
local hole = c:ellipse(18, 17, 4.5, 6)
hole:cut(c:rect(13, 11, 13, 12)):cut(c:rect(22, 11, 22, 12))
local ring = outer:copy():cut(hole)
local rb = {}
ring:each(function(x, y) if hole:has(x, y - 1) then rb[K(x, y)] = -1 end end)
local rI, rT = O.shade(c, ring, STN, { R = 4, bias = rb, amb = .1, wrap = .3, sep = STN[1], rim = true, bounce = "#7a8ab8", bmax = 2 })
O.tex(c, rI, rT, STN, function(x, y, i) if y < 21 and H(x, y, 13) > .9 and i >= 2 and i <= 5 then return 1 end end)
O.dots(c, { { 9, 16 }, { 26, 13 } }, "#b48a98") O.dot(c, 10, 19, "#e0b8bc") O.dot(c, 27, 23, "#8a9048")
-- inner arch: the top inner wall faces down (dark), the sill faces up (lit)
hole:each(function(x, y)
  if not hole:has(x, y - 1) and y < 15 then c:put(x, y, "#3a3a58", rT) end
end)
for x = 13, 23 do for y = 20, 25 do

  if ring:has(x, y) and hole:has(x, y - 1) then c:put(x, y, x < 19 and STN[5] or STN[4], rT) break end
end end
-- a wisp of cloud along the bottom of the hole (the hole stays open above it)
local cl = O.unionCircles{ { 17, 21, 2.5, 1.2 }, { 20, 20.5, 1.5, 1.2 } }
cl:clip(hole)
O.shade(c, cl, CLD, { R = 1, amb = .4, cuts = { .35, .6, .85 } })
local snow = HP.mask()
outer:each(function(x, y)
  local hem = 9 + ((x % 3 == 0) and 1 or 0) + ((x < 12 or x > 24) and 3 or 0) + ((x == 12 or x == 24) and 1 or 0)
  if y <= hem then snow:set(x, y) end
end)
snow:add(c:ellipse(18, 8.5, 7, 2)):add(c:ellipse(11, 11, 2, 2)):add(c:ellipse(25, 11, 2, 2))
snow:cut(hole)

local sI, sT = O.shade(c, snow, SNOW, { R = 2, amb = .3, wrap = .4, sep = SNOW[1], cuts = { .25, .5, .72, .88 }, rim = true })
O.dot(c, 13, 8, SNOW[5])
for x = 0, 35 do for y = 6, 20 do
  if c.own[y * 36 + x] == rT and c.own[(y - 1) * 36 + x] == sT then c.pix[y * 36 + x] = "#4a5478" break end
end end
O.dots(c, { { 16, 11 }, { 20, 11 } }, SNOW[3]) -- two short icicles

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
