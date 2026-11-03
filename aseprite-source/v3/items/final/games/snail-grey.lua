local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- snail-grey: a squat, flat, wide slate shell cracked like old stone, low blue-grey body, short stalks.
-- quirk: the snail wears a gold monocle on one eye, with a chain trailing down.
local c = D.new("snail-grey")
local BODY = { "#5a6070", "#7c8498", "#9aa4b4", "#b4bcc8", "#d0d6dc", "#e8ecee" }
local SH = { "#3a3c58", "#545a78", "#74788c", "#9296a8", "#b0b4c4", "#d8dae4" }
c:groundShadow(30, 56, 26, 2)
local bm = D.sweep({ {6, 52}, {26, 55}, {46, 54}, {53, 42} }, function(t) return t < 0.25 and 1 + t * 11 or 3.6 end, 60)
bm:add(c:ellipse(53, 41, 4, 4))
D.lit(c, bm, BODY, 3, { amb = 0.15 })
for x = 12, 48 do if bm:has(x, 56) then D.shift(c, x, 56, BODY, -2) end end
D.stalk(c, 50, 38, 50, 31, BODY[2])
D.stalk(c, 55, 38, 56, 31, BODY[2])
c:px(56, 43, BODY[1]) c:px(57, 43, BODY[1])
local shm = c:ellipse(27, 41, 18, 11)
D.lit(c, shm, SH, 7, { amb = 0.1 })
D.seam(c, bm, shm, BODY[1])
-- coil lines and cracks
D.spiral(c, 27, 42, 9, 1.6, SH[2], shm, 2.2)
D.polyline(c, { {18, 32}, {21, 35}, {20, 38}, {23, 41} }, SH[1])
D.polyline(c, { {36, 31}, {34, 35}, {37, 38} }, SH[1])
c:px(14, 38, SH[6]) c:px(15, 37, SH[6]) c:px(15, 38, SH[5]) c:px(16, 36, CREAM)
-- monocle on right eye (stalk tip around 56,31)
D.ring(c, 55, 27, 3, "#f5b82e") D.ring(c, 55, 27, 3.2, "#d98322")
c:px(53, 26, CREAM)
D.polyline(c, { {57, 30}, {59, 36}, {59, 42} }, "#f5b82e")
D.fin()
