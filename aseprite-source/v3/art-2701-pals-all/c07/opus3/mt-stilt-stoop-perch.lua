-- Stilt Stoop (mt-stilt-stoop), perch sprite 36x36, hand-built at this size (opus3 richness pass, from opus2).
-- opus3: red hat band, frayed brim ends, plank seam and pegs, a bamboo leaf, fuzz freckles, an orange minnow.
-- Amber round body under a straw cone hat, a wood plank stoop, two 2 px bamboo stilts with one node each,
-- standing in a canal strip. Big pill eyes under the brim.
-- quirk: one mitten raised in a wave.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mt-stilt-stoop-perch", 36)

local AMB  = { "#6a3020", "#9a4a24", "#c86e2a", "#e8963a", "#f8bc5c", "#ffdc96" }
local BAM  = { "#3a4a24", "#55692c", "#7a8c36", "#a2ac48", "#c8c870", "#e8e4a0" }
local STR  = { "#6a4422", "#8e6230", "#b88a44", "#d8b060", "#ecd088", "#faecb4" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local SEA  = { "#3a86b0", "#5fc4c8", "#b6f0e0" }

local water = c:ellipse(17, 30, 11, 1.2)
O.flat(c, water, SEA[2], "water")
for _, sx in ipairs({ 13, 20 }) do
  O.shade(c, c:rect(sx, 21, sx + 1, 30), BAM, { R = 1, amb = .35, wrap = .4, sep = BAM[1] })
  O.dots(c, { { sx, 26 }, { sx + 1, 26 } }, BAM[2]) O.dot(c, sx, 27, BAM[5])
end
O.dots(c, { { 11, 30 }, { 12, 30 }, { 15, 30 }, { 18, 30 }, { 19, 30 }, { 22, 30 }, { 23, 30 } }, SEA[3])
O.dots(c, { { 16, 30 }, { 17, 30 } }, "#f08a3a") -- minnow
O.shade(c, c:poly{ { 13, 25 }, { 10, 23 }, { 8, 24 }, { 11, 26 } }, BAM, { R = 1, amb = .4, sep = BAM[1] }) -- leaf
-- waving arm + hand
local arm, an = O.tube({ { 23, 16 }, { 26, 14 }, { 28, 11 }, { 29, 8 } }, function() return 1.2 end)
O.shadeN(c, arm, an, AMB, { amb = .3, sep = AMB[1] })
local hand = c:ellipse(29.5, 6.5, 2, 2) hand:add(c:rect(28, 3, 28, 4)) hand:add(c:rect(30, 3, 30, 4))
O.shade(c, hand, AMB, { R = 1, amb = .35, sep = AMB[1] })
-- body
local body = c:ellipse(17, 15, 8, 7)
local bI, bT = O.shade(c, body, AMB, { sphere = { 14, 11, 12 }, amb = .3, wrap = .45, sep = AMB[1], rim = true, bounce = "#7a5a8a", bmax = 2 })
O.tex(c, bI, bT, AMB, function(x, y, i) if (x < 12 or x > 23 or y > 18) and O.H(x, y, 5) > .9 and i >= 3 then return -1 end end)
O.shade(c, c:rect(8, 21, 26, 22), WOOD, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = WOOD[1], rim = true })
O.dots(c, { { 12, 21 }, { 21, 21 } }, "#d8b060") O.dots(c, { { 15, 22 }, { 16, 22 }, { 24, 22 } }, WOOD[1])
-- hat
local hat = c:poly{ { 16, 1 }, { 17, 1 }, { 28, 9 }, { 26, 10 }, { 7, 10 }, { 5, 9 } }
local hb = {} hat:each(function(x, y) if y % 3 == 0 then hb[K(x, y)] = -1 end end)
O.shade(c, hat, STR, { R = 2, amb = .3, wrap = .45, bias = hb, sep = STR[1] })
O.flat(c, c:rect(7, 10, 26, 10), STR[2], "brim")
O.dots(c, { { 8, 11 }, { 13, 11 }, { 20, 11 }, { 25, 11 } }, STR[3]) -- frayed ends
for x = 12, 21 do O.dot(c, x, 8, (x % 3 == 0) and "#e8493b" or "#b52e3f") end -- hat band
-- face
c:eyeSmall(13, 13)
c:eyeSmall(20, 13)
O.dot(c, 11, 17, "#f5809f") O.dot(c, 24, 17, "#f5809f")
O.dots(c, { { 16, 17 }, { 17, 17 }, { 18, 17 }, { 17, 18 } }, "#3e1620")
O.shift(c, -1, 1)
O.done(c, "mt-stilt-stoop-perch", function(c)
  for _, p in ipairs({ { 32, 5 }, { 32, 8 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#fff4d6", { r = { name = "tick" } }) end end
end)
