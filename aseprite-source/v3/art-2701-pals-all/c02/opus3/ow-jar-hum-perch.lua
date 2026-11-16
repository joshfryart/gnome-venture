-- Jar Hum (ow-jar-hum), perch sprite 36x36. Opus richness pass (c02/opus3), built on opus2, hand-built at this size.
-- Richness (opus3): throwing rings + grog flecks below the face, handle rim/bounce, a bold 1 px olive-oil drip
-- with a lit bead from the lip, cork pores, tiny jar banded and rim-lit.
-- Terracotta amphora with open loop handles, cream shoulder band, cork with a wooden peg (peg knob), humming "o".
-- Fix vs Haiku: potion-flask read and dot "waves" replaced by a real amphora and one bold gold note.
-- quirk: the tiny oil jar beside it, humming back.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-jar-hum-perch", 36)

local CLAY = { "#4a2026", "#7a3328", "#a8502e", "#cc7340", "#e69a5c", "#f6c48a" }
local SLIP = { "#7a5a48", "#a88a6c", "#cdb28a", "#e6d0a6", "#f4e4c0", "#fbf0d6" }
local CORK = { "#4e3424", "#7a5636", "#a37a4c", "#c89e66", "#e2c288" }
local GOLD = { "#8a5a1c", "#c98a26", "#f0b83a", "#fde08a" }

c:groundShadow(18, 31, 14, 1.2)

for _, sd in ipairs({ -1, 1 }) do
  local hx = function(x) return 15 + sd * x end
  local h = O.tube({ { hx(1), 9 }, { hx(7), 7 }, { hx(8), 14 }, { hx(5), 16 } }, function(t) return 1 end)
  O.shade(c, h, CLAY, { R = 1, amb = .25, wrap = .35, rim = true, bounce = "#6a5a8a", bmax = 2 })
end
local body = c:ellipse(15, 22, 9, 7.5)
body:add(c:ellipse(15, 16, 6.5, 3))
body:add(c:rect(13, 7, 17, 14))
body:add(c:rect(12, 29, 18, 31))
local bb = {}
body:each(function(x, y) if y >= 30 then bb[K(x, y)] = -1 end if y == 29 then bb[K(x, y)] = -2 end end)
local bI, bT = O.shade(c, body, CLAY, { sphere = { 11, 16, 13 }, bias = bb, amb = .2, wrap = .35, rim = true, bounce = "#6a5a8a", bmax = 2 })
O.tex(c, bI, bT, CLAY, function(x, y, i)
  if y >= 27 and y <= 28 and (x + y) % 3 == 0 and i >= 3 then return -1 end
  if (y < 19 or y > 26 or x < 9 or x > 22) and H(x, y, 17) > .94 and i >= 2 then return 1 end
end)
O.retone(c, bI, bT, SLIP, function(x, y, i) return y >= 16 and y <= 17 end)
O.retone(c, bI, bT, { "#3a2026", "#4a2a2c", "#5a3430", "#6a3e34", "#6a3e34", "#6a3e34" }, function(x, y, i)
  return (y == 16 and x % 3 == 0) or (y == 17 and x % 3 == 1)
end)
O.shade(c, c:ellipse(15, 7, 3.5, 1), CLAY, { R = 1, amb = .35, sep = CLAY[2] })
local cork = c:rect(12, 3, 18, 6) cork:cut(c:rect(12, 3, 12, 3)) cork:cut(c:rect(18, 3, 18, 3))
O.shade(c, cork, CORK, { R = 1, amb = .25, sep = CORK[1], cuts = { .25, .45, .65, .84 } })
O.dots(c, { { 16, 9 }, { 16, 10 }, { 16, 11 } }, "#d8c04c") O.dot(c, 16, 12, "#f4e48a") -- oil drip
O.dot(c, 14, 4, "#7a5636") O.dot(c, 17, 5, "#7a5636") -- cork pores
O.flat(c, c:rect(15, 1, 15, 2), "#864c33", "peg")
O.dot(c, 15, 1, "#e8b982")

-- face
c:eyeSmall(11, 20)
c:eyeSmall(18, 20)
O.dot(c, 9, 24, "#f5809f") O.dot(c, 21, 24, "#f5809f")
O.dots(c, { { 15, 24 }, { 14, 25 }, { 16, 25 }, { 15, 26 } }, P.ink)
O.dot(c, 15, 25, "#7a2c34")
O.dot(c, 9, 19, CLAY[6])

-- note
O.flat(c, c:rect(2, 14, 4, 15), GOLD[3], "note") O.dot(c, 2, 14, GOLD[4])
O.flat(c, c:rect(4, 10, 4, 13), GOLD[2], "note") O.dots(c, { { 5, 11 }, { 6, 12 } }, GOLD[2])

-- quirk: tiny jar humming back
local tj = c:ellipse(29, 27, 3.5, 3.5)
tj:add(c:rect(28, 22, 30, 24))
local jI, jT = O.shade(c, tj, CLAY, { sphere = { 28, 25, 6 }, amb = .25, wrap = .35, rim = true, bounce = "#6a5a8a", bmax = 2 })
O.retone(c, jI, jT, SLIP, function(x, y) return y == 24 end)
O.flat(c, c:rect(28, 21, 30, 21), CORK[3], "cork")
O.dots(c, { { 28, 26 }, { 30, 26 } }, P.ink) O.dot(c, 29, 28, P.ink)
O.flat(c, c:rect(31, 16, 32, 17), GOLD[3], "note") O.flat(c, c:rect(32, 13, 32, 15), GOLD[2], "note")

O.shift(c, 0, 1)
O.done(c, "ow-jar-hum-perch")
