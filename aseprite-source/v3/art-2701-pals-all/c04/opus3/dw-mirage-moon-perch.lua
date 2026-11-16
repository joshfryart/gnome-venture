-- Mirage Moon (dw-mirage-moon), perch sprite 36x36. Opus second pass (c04/opus2), hand-built at this size:
-- the cradle moon (honey-cream, lavender shading lower right) with the face on its thick belly (2x3 pills,
-- ink smile, cheeks), one sparkle, a strip of dune.
-- quirk: a tiny camel on the dune, its eye a 2 px ink line (blinking at the moon).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("dw-mirage-moon-perch", 36)

local MOON  = { "#4a3a6e", "#7a5a8e", "#b4849a", "#e0b07e", "#f2d48e", "#fbeec0" }
local DUNE  = { "#7a4a3a", "#a86a44", "#d0924e", "#e8b868", "#f5d494" }
local CAMEL = { "#4a2a24", "#7a4a30", "#a8703e", "#c99458", "#e3b878" }

local dune = c:ellipse(29, 35, 5, 2.5) dune:cut(c:rect(0, 34, 40, 40))
O.shade(c, dune, DUNE, { R = 2, amb = .3, wrap = .4, cuts = { .3, .5, .7, .85 } })
-- camel, hand-placed (facing the moon)
local CAM = {
  ".hhh.....",
  "hhee.....",
  "..nn.....",
  "..nn.uu..",
  "..nbbuub.",
  "..bbbbbbt",
  "..dddddd.",
  "..l.l.ll.",
  "..l.l..l.",
  "..l.l..l." }
local CM = { h = CAMEL[4], e = CAMEL[4], n = CAMEL[4], u = CAMEL[5], b = CAMEL[4], d = CAMEL[3], l = CAMEL[3], t = CAMEL[3] }
for j, row in ipairs(CAM) do for i = 1, #row do
  local ch = row:sub(i, i)
  if CM[ch] then O.dot(c, 24 + i, 21 + j, CM[ch]) end
end end
O.dots(c, { { 27, 23 }, { 28, 23 } }, P.ink) -- the blink
O.dot(c, 26, 22, CAMEL[5]) O.dot(c, 25, 23, CAMEL[2])

-- moon
local CX = 14
local moon = c:ellipse(CX, 17, 12, 12)
moon:cut(c:ellipse(CX, 6.5, 11.5, 11.5))
local bias = {}
moon:each(function(x, y) if x - CX + (y - 18) * .6 > 8 then bias[K(x, y)] = -1 end end)
O.shade(c, moon, MOON, { R = 4, bias = bias, amb = .2, wrap = .35, rim = true, bounce = "#8a7ab8", bmax = 3 })
O.mark(c, { { 4, 18 }, { 5, 18 } }, MOON[3])

c:eyeSmall(9, 21)
c:eyeSmall(18, 21)
O.dot(c, 7, 24, "#f5809f") O.dot(c, 21, 24, "#f5809f")
O.dots(c, { { 12, 25 }, { 13, 26 }, { 14, 26 }, { 15, 25 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "dw-mirage-moon-perch", function(c) c:sparkle(31, 6) end)
