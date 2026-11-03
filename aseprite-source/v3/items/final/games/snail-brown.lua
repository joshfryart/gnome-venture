local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- snail-brown: classic garden snail, coiled chestnut shell with a spiral groove, cream body, slim tail.
-- quirk: it wears an acorn cap like a tiny helmet on top of the shell.
local c = D.new("snail-brown")
local BODY = { "#7a5a48", "#a88268", "#c8a384", "#dcbf9c", "#ecd6b4", "#f8e8cc" }
local SH = { "#3e2220", "#5e3a2e", "#7e5036", "#9a6a42", "#b88650", "#d8a868" }
local CAP = { "#3a2220", "#51302b", "#6e4430", "#8a5a38", "#a8764a", "#c89868" }
c:groundShadow(30, 56, 25, 2)
local bm = D.sweep({ {7, 52}, {26, 55}, {46, 53}, {53, 36} }, function(t) return t < 0.25 and 1 + t * 11 or (t > 0.8 and 3.8 - (t - 0.8) * 5 or 3.8) end, 60)
bm:add(c:ellipse(53, 35, 4, 4))
D.lit(c, bm, BODY, 3, { amb = 0.15 })
-- foot sole line
for x = 14, 46 do if bm:has(x, 55) then D.shift(c, x, 55, BODY, -2) end end
D.stalk(c, 50, 32, 49, 22, BODY[2])
D.stalk(c, 55, 32, 56, 24, BODY[2])
c:px(56, 38, BODY[1]) c:px(57, 38, BODY[1])
local shm = c:ellipse(28, 35, 14, 14)
D.disc(c, 28, 35, 14, SH)
D.spiral(c, 28, 36, 12, 2.4, SH[2], shm, 3.5)
D.spiral(c, 27, 35, 11, 2.4, SH[5], shm, 3.5)
D.seam(c, bm, shm, BODY[1])
-- cap hat
local cap = c:ellipse(28, 21, 7, 5):clip(c:rect(0, 0, 63, 21))
D.lit(c, cap, CAP, 3, { amb = 0.1 })
cap:each(function(x, y) if (x + y) % 3 == 0 then D.shift(c, x, y, CAP, -1) end end)
c:fillMask(c:rect(21, 22, 35, 22), CAP[1])
c:part(c:rect(27, 15, 29, 17), "wood", { band = 1 })
c:px(20, 32, "#f8d8a0") c:px(20, 31, "#f8d8a0") c:px(21, 30, CREAM)
D.fin()
