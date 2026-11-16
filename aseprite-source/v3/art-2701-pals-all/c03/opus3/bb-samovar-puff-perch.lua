-- Samovar Puff (bb-samovar-puff), perch sprite 36x36. Opus richness pass (c03/opus3), hand-built at this size.
-- Richness pass: hue-shifted brass ramp, a specular streak, lit flute ridges, three stamped medals on the band,
-- a blue-painted cup; the face area is kept clean so the pill eyes read.
-- Same pear urn, collar, chimney and one curly steam puff as the yard, but fewer, bolder parts: plinth, two ring
-- handles, pill eyes on the belly with a wide smile. quirk: the open tap overflowing a tiny cup on a saucer.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("bb-samovar-puff-perch", 36)

local BR   = { "#46201c", "#7a3a20", "#a85e28", "#d4963a", "#eec468", "#faeaae" }
local DK   = { "#3a1c16", "#5c2e1a", "#86501f", "#b07a2c", "#d6a84a", "#eccf7e" }
local STM  = { "#7c7f9e", "#a6a9c2", "#cdd0e0", "#eceef5" }
local TEA  = { "#4e2212", "#7e3c18", "#b5662a", "#dc9a4e" }
local CUP  = { "#5a5c84", "#8a8db0", "#bfc2d8", "#e6e8f1" }

c:groundShadow(18, 32, 13, 1.5)
local plinth = c:poly{ { 12, 27 }, { 21, 27 }, { 24, 31 }, { 9, 31 } }
O.shade(c, plinth, DK, { R = 1, amb = .25, sep = DK[1] })
for _, hx in ipairs({ 7, 26 }) do
  local ring = c:ellipse(hx, 18, 2, 2.5)
  ring:cut(c:rect(hx, 17, hx, 18))
  O.shade(c, ring, DK, { R = 1, amb = .3 })
end
local body = c:ellipse(16.5, 21, 8.5, 6.5)
body:add(c:ellipse(16.5, 16.5, 6, 3.5))
local bI, bT = O.shade(c, body, BR, { sphere = { 14, 17, 10 }, amb = .2, wrap = .4, sep = BR[1], rim = true, bounce = "#8a6a8c", bmax = 2 })
O.tex(c, bI, bT, BR, function(x, y, i)
  if y >= 25 and (x - 16) % 3 == 0 and i >= 2 then return -1 end
  if y >= 25 and (x - 16) % 3 == 1 and i <= 5 then return 1 end
  if x == 10 and y >= 17 and y <= 23 and i >= 3 then return 6 - i end -- specular streak
end)
for x = 8, 25 do if body:has(x, 15) then c:put(x, 15, BR[2], bT) end end
O.mark(c, { { 12, 16 }, { 16, 16 }, { 20, 16 } }, BR[6]) O.mark(c, { { 13, 16 }, { 17, 16 }, { 21, 16 } }, BR[3]) -- medals
local collar = c:rect(13, 11, 20, 12)
O.shade(c, collar, DK, { R = 1, amb = .35, sep = DK[1] })
O.shade(c, c:rect(15, 7, 18, 10), BR, { R = 1, amb = .3, sep = BR[1] })
O.flat(c, c:rect(14, 6, 19, 6), DK[4], "cap") O.dot(c, 14, 6, DK[6])
local stm = O.unionCircles{ { 14.5, 4, 1.8, 1.4 }, { 17.5, 3.2, 2.2, 1.6 }, { 20.5, 4, 1.5, 1.2 } }
O.shade(c, stm, STM, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.dots(c, { { 17, 3 }, { 18, 4 } }, STM[2])

-- tap and the overflowing cup
O.dots(c, { { 24, 24 }, { 25, 24 }, { 26, 25 } }, DK[4])
O.dot(c, 25, 23, BR[5])
O.dot(c, 27, 26, TEA[3])
local cup = c:rect(27, 27, 31, 30)
O.shade(c, cup, CUP, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = CUP[1] })
O.dots(c, { { 27, 27 }, { 28, 27 }, { 29, 27 }, { 30, 27 }, { 31, 27 }, { 28, 26 }, { 29, 26 }, { 30, 26 } }, TEA[3])
O.dot(c, 29, 26, TEA[4]) O.dot(c, 27, 28, TEA[2])
O.dot(c, 32, 28, CUP[2])
O.mark(c, { { 28, 29 }, { 30, 29 } }, "#3a5aa8")
O.flat(c, c:rect(25, 31, 33, 31), CUP[3], "saucer") O.dot(c, 26, 31, TEA[3])

-- face
c:eyeSmall(12, 19) c:eyeSmall(19, 19)
O.dot(c, 10, 23, "#f5809f") O.dot(c, 23, 23, "#f5809f")
O.dots(c, { { 14, 23 }, { 15, 24 }, { 16, 24 }, { 17, 24 }, { 18, 23 } }, P.ink)

O.done(c, "bb-samovar-puff-perch")
