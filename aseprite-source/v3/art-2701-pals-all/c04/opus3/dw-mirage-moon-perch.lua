-- Mirage Moon (dw-mirage-moon), perch sprite 36x36. Opus richness pass (c04/opus3), hand-built at this size.
-- Richness pass: hue-shifted dune with wind ripples, two ringed craters and a maria patch on the moon, the camel
-- shaded in 4 tones with a red saddle blanket. Fixed from opus2: the camel blink was a 2 px line; now a bigger head
-- with a v-shaped squeezed eye, a lash and three blink ticks above it. From opus2:
-- the cradle moon (honey-cream, lavender shading lower right) with the face on its thick belly (2x3 pills,
-- ink smile, cheeks), one sparkle, a strip of dune.
-- quirk: a tiny camel on the dune, eye squeezed shut in a blink (dazzled by the moon).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("dw-mirage-moon-perch", 36)

local MOON  = { "#4a3a6e", "#7a5a8e", "#b4849a", "#e0b07e", "#f2d48e", "#fbeec0" }
local DUNE  = { "#6e3e42", "#a0644a", "#cc8e50", "#e6b66a", "#f5d494" }
local CAMEL = { "#4a2a24", "#7a4a30", "#a8703e", "#c99458", "#e3b878" }

-- moon
local CX = 14
local moon = c:ellipse(CX, 17, 12, 12)
moon:cut(c:ellipse(CX, 6.5, 11.5, 11.5))
local bias = {}
moon:each(function(x, y) if x - CX + (y - 18) * .6 > 8 then bias[K(x, y)] = -1 end end)
O.shade(c, moon, MOON, { R = 4, bias = bias, amb = .2, wrap = .35, rim = true, bounce = "#8a7ab8", bmax = 3 })
local mI, mT = nil, nil
O.mark(c, { { 4, 18 }, { 5, 18 } }, MOON[3]) O.mark(c, { { 4, 19 }, { 5, 19 } }, MOON[6])
O.mark(c, { { 22, 18 }, { 23, 18 } }, MOON[3]) O.mark(c, { { 22, 19 }, { 23, 19 } }, MOON[5])
O.mark(c, { { 6, 14 }, { 7, 14 }, { 7, 15 } }, MOON[4])

c:eyeSmall(9, 21)
c:eyeSmall(18, 21)
O.dot(c, 7, 24, "#f5809f") O.dot(c, 21, 24, "#f5809f")
O.dots(c, { { 12, 25 }, { 13, 26 }, { 14, 26 }, { 15, 25 } }, P.ink)

-- moon nudged left so the camel stands clear of its horn; dune and camel in front
O.shift(c, -1, 0)
local dune = c:ellipse(30, 35, 6, 2.5) dune:cut(c:rect(0, 34, 40, 40))
local dI, dT = O.shade(c, dune, DUNE, { R = 2, amb = .3, wrap = .4, cuts = { .3, .5, .7, .85 } })
-- camel, hand-placed (facing the moon): h head, m muzzle, n neck, u hump, b body, B blanket, d belly, l legs, t tail
local CAM = {
  "..hhh.....",
  ".hhhhh....",
  "mmhh......",
  "..nn..u...",
  "..nn.uuu..",
  "..nbuuuuu.",
  "..bBBBBbbt",
  "..ddddddd.",
  "..l....l..",
  "..l....l..",
  "..l....l.." }
local CM = { h = CAMEL[4], m = CAMEL[3], n = CAMEL[4], u = CAMEL[5], b = CAMEL[4], B = "#b43c48", d = CAMEL[3], l = CAMEL[3], t = CAMEL[2] }
for j, row in ipairs(CAM) do for i = 1, #row do
  local ch = row:sub(i, i)
  if CM[ch] then O.dot(c, 25 + i, 20 + j, CM[ch]) end
end end
O.dots(c, { { 29, 27 }, { 31, 27 } }, "#f5c84a") -- blanket stitches
O.dots(c, { { 27, 21 }, { 28, 21 } }, CAMEL[5]) -- lit brow
O.dots(c, { { 32, 25 }, { 31, 24 } }, CAMEL[5]) -- lit hump
-- the blink: a shut lid line with a lash flicking up
O.dots(c, { { 27, 22 }, { 28, 22 } }, P.ink) O.dot(c, 29, 21, P.ink)
O.dot(c, 26, 23, CAMEL[1]) -- nostril

O.shift(c, 0, -1)
O.done(c, "dw-mirage-moon-perch", function(c)
  c:sparkle(31, 6)
  for _, t in ipairs({ { 26, 18 }, { 28, 17 }, { 30, 18 } }) do c:put(t[1], t[2], "#fbeec0") end -- blink ticks
end)
