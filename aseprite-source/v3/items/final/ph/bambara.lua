local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bambara: two round cream groundnuts with a dark eye ring plus a wrinkled open pod holding a third, on a tiny trifoliate stalk. quirk: one nut's eye ring is red-brown like a tiny eye.
local c = D.new("bambara")
c:groundShadow(32, 54, 15, 2)
D.stem(32, 14, 32, 22, "#5a8a48") D.stem(33, 14, 33, 22, "#3f7a44")
D.lf(26, 12, 4, 2.2, -0.5, D.LEAF2) D.lf(38, 12, 4, 2.2, 0.5, D.LEAF2) D.lf(32, 8, 2.2, 4, 0, D.LEAF2)
-- pod
local pod = c:ellipse(40, 40, 11, 13) D.lit(pod, D.TAN, 4)
pod:each(function(x, y) if (x * 2 + y * 3) % 9 == 0 then c:px(x, y, D.TAN[2]) end end)
D.lit(D.ell(40, 38, 6.5, 8.5, 0), D.CRM, 3)
-- nuts
local NUT = { "#7a5a46", "#a8826a", "#d2b08c", "#ecd2ae", "#f8e6c8", "#fffaec" }
local n1 = D.ell(22, 44, 8, 8, 0) D.lit(n1, NUT, 4)
local n2 = D.ell(36, 38, 5.4, 5.4, 0) D.lit(n2, NUT, 3)
local n3 = D.ell(30, 28, 5, 5, 0) D.lit(n3, NUT, 3)
c:fillMask(D.ell(25, 46, 2.4, 2.4, 0), "#6a2a2a") c:fillMask(D.ell(25, 46, 1.2, 1.2, 0), "#2b1c26") c:px(24, 45, "#fff4d6")
c:fillMask(D.ell(33, 40, 1.5, 1.5, 0), "#3a2a2e") c:px(31, 26, "#3a2a2e") c:px(32, 27, "#3a2a2e")
D.fin()
