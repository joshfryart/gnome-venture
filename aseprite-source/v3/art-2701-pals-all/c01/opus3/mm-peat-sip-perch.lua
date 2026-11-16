-- Peat Sip (mm-peat-sip), perch sprite 36x36. Opus third pass (c01/opus3), richness pass over opus2: an eave
-- shadow under the roof, bricks with their own tones, a dark sod edge with a drooping grass fringe, a few lit
-- grass tufts, chimney soot and an ember glow in the flue.
-- Peat croft: brick walls (bed joints every 4 px, staggered head joints), a mounded turf roof with one
-- yellow flower, a stone chimney with one smoke puff, foundation-stone feet; pill eyes and a round
-- humming mouth on the wall.
-- quirk: the smoke music note, here a 4x5 note next to the puff.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mm-peat-sip-perch", 36)

local PEAT = { "#24161e", "#3e2626", "#5c3a2e", "#7e5238", "#a07048", "#c4986a" }
local TURF = { "#1f3a30", "#2f5a3a", "#4a7e44", "#6fa452", "#9cc86a", "#cce496" }
local STN  = { "#33344a", "#4d4f67", "#6b6d86", "#8d8fa5", "#b0b1c2", "#d2d2dc" }
local SMK  = { "#8a8496", "#b2acba", "#d6d0d8", "#eeeaee" }

c:groundShadow(18, 32, 11, 1.5)
for _, fx in ipairs({ 12, 23 }) do O.shade(c, c:rect(fx - 3, 29, fx + 3, 30), STN, { R = 1, amb = .25, sep = STN[1] }) end
local ch = c:rect(22, 8, 25, 15)
O.shade(c, ch, STN, { R = 1, amb = .2, wrap = .35, sep = STN[1], rim = true })
O.flat(c, c:rect(22, 8, 25, 8), STN[1], "flue") O.dots(c, { { 23, 8 }, { 24, 8 } }, "#e0702a")
O.mark(c, { { 22, 9 }, { 23, 9 }, { 24, 9 }, { 25, 9 } }, STN[2])
local wall = c:rrect(7, 17, 28, 29, 1)
local wb = {}
wall:each(function(x, y) if y <= 20 then wb[K(x, y)] = -1 end end)
local wI, wT = O.shade(c, wall, PEAT, { R = 4, bias = wb, amb = .35, wrap = .45, sep = PEAT[1], rim = true, bounce = "#5a5a7a", bmax = 2 })
O.tex(c, wI, wT, PEAT, function(x, y, i)
  local face = x > 10 and x < 26 and y > 19 and y < 27
  if face then return end
  local row = (y - 17) // 4
  if (y - 17) % 4 == 3 then return -1 end
  if (x + row * 3) % 6 == 0 then return -1 end
  local b = O.H((x + row * 3) // 6, row, 3)
  return (b > .7) and 1 or ((b < .25) and -1 or 0)
end)
local roof = c:ellipse(17.5, 18, 13, 7)
roof:cut(c:rect(0, 19, 35, 35)):add(c:rect(4, 18, 31, 19))
roof:cut(ch:copy():cut(c:rect(0, 13, 35, 35)))
local tI, tT = O.shade(c, roof, TURF, { R = 2, amb = .2, wrap = .35, sep = TURF[1], rim = true })
O.dots(c, { { 12, 13 }, { 14, 12 }, { 17, 12 }, { 8, 16 }, { 20, 14 } }, TURF[5]) O.dots(c, { { 12, 14 }, { 17, 13 }, { 20, 15 } }, TURF[3])
for x = 4, 31 do
  if c.own[19 * 36 + x] == tT then c.pix[19 * 36 + x] = (x % 3 == 0) and PEAT[3] or PEAT[2] end
end
for _, x in ipairs({ 6, 9, 27 }) do O.dot(c, x, 20, TURF[3]) end

O.dots(c, { { 10, 15 }, { 12, 15 }, { 11, 14 }, { 11, 16 } }, "#f0c43a") O.dot(c, 11, 15, "#d0802a")
O.shade(c, c:ellipse(25, 5.5, 2, 1.2), SMK, { R = 1, amb = .35, cuts = { .35, .6, .85 } })
local note = c:rect(30, 3, 30, 7):add(c:rect(28, 7, 29, 8)):add(c:rect(31, 3, 31, 4))
O.flat(c, note, SMK[3], "note") O.dot(c, 28, 7, SMK[4]) O.dot(c, 29, 8, SMK[1])
c:eyeSmall(12, 20)
c:eyeSmall(22, 20)
O.dot(c, 10, 24, P.petal.base) O.dot(c, 25, 24, P.petal.base)
O.dots(c, { { 17, 24 }, { 18, 24 }, { 16, 25 }, { 19, 25 }, { 17, 26 }, { 18, 26 } }, P.ink)
O.dots(c, { { 17, 25 }, { 18, 25 } }, "#8a3a48")
O.done(c, "mm-peat-sip-perch")
