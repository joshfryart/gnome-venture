-- bird-box: a slim hanging nest box, board front, round hole, short perch and a shingled roof on a short post. quirk: a blue tit pokes its head out of the hole with a tiny feather stuck to the beak.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bird-box")
local W, RF = D.WD, { "#3a1c3c", "#5a2a50", "#7a3c68", "#a0508a", "#c47cb0", "#e8b0d4" }
D.sh(32, 58, 12, 2)
-- post
local post = c:rect(30, 50, 34, 58) D.vc(post, W, 30, 34)
-- body
local body = c:rect(18, 28, 46, 52)
D.vc(body, W, 18, 46, { wrap = .35 })
-- board lines
for x = 24, 40, 6 do for y = 28, 52 do c:px(x, y, W[2]) end end
for y = 34, 48, 7 do c:px(20, y, W[5]) c:px(33, y + 2, W[5]) end
-- roof
local roof = c:poly{ {13,30}, {32,12}, {51,30}, {47,31}, {32,19}, {17,31} }
D.lit(roof, RF, 2.2)
local roof2 = c:poly{ {13,30}, {32,12}, {51,30}, {47,31}, {32,19}, {17,31} }
for y = 16, 30 do for x = 12, 52 do if roof:has(x, y) and (y + floor(x / 3) * 2) % 5 == 0 then c:px(x, y, RF[2]) end end end
-- hole
local hole = D.ell(32, 38, 5, 5, 0)
D.lit(hole, { "#14080e", "#241018", "#3a1c20", "#3a1c20", "#51302b", "#51302b" }, 3)
-- perch
c:px(30, 46, W[6]) c:px(31, 46, W[6]) c:px(32, 46, W[5]) c:px(33, 46, W[4]) c:px(34, 46, W[3]) c:px(35, 46, W[3])
D.ln(32, 44, 32, 46, W[2])
-- bird head: blue tit
local head = D.ell(32, 38, 3.6, 3.2, 0)
D.lit(head, { "#1c3a78", "#2c58a8", "#4a82d0", "#fff4d6", "#fff4d6", "#fff4d6" }, 2)
c:paint({ "xxxxxxx" }, 29, 36, { x = "#4a82d0" })
c:px(30, 38, "#2b1c26") c:px(30, 37, "#fff4d6")
c:paint({ "yy", ".y" }, 33, 38, { y = "#f8a82e" })
c:px(36, 37, "#f4f2ff") c:px(37, 36, "#f4f2ff") c:px(37, 37, "#c8c4d8")
D.fin()
