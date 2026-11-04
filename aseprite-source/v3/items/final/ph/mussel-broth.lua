-- mussel-broth: stone-blue bowl of golden broth with two blue-black mussels, one open with orange flesh. quirk: steam curls up into a little question-mark.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mussel-broth")
local BW = D.R("#d4e8f6", "#8aa4c8", "#566a9c", "#323a68")
local BR = D.R("#ffe38a", "#f5b82e", "#d98322", "#8f4a1f")
local MS = D.R("#8aa0d8", "#3a4c98", "#252c68", "#151a3c")
c:groundShadow(32, 57, 20, 2)
local body = c:ellipse(32, 36, 21, 18):cut(c:rect(0, 0, 63, 35))
B.lit(c, body, BW, 10)
for _, y in ipairs{ 42, 46 } do for x = 16, 48 do if body:has(x, y) and (x + y) % 5 == 0 then c:px(x, y, BW.shade) end end end
local rim = c:ellipse(32, 35, 22, 6)
B.lit(c, rim, BW, 4)
local soup = c:ellipse(32, 35, 19, 4)
B.lit(c, soup, BR, 3)
c:fillMask(c:rect(25, 34, 28, 34), "#fff4d6")
-- parsley
for _, p in ipairs{ {40,36}, {43,35}, {22,36} } do c:px(p[1], p[2], "#3f9150") c:px(p[1] + 1, p[2], "#7cc35a") end
-- mussels
local m1 = B.ell(25, 30, 7, 4.2, -0.5)
B.lit(c, m1, MS, 3)
for i = -2, 2 do B.ln(c, 22 + i, 33 + i * .2, 27 + i * 2, 26, MS.deep, m1) end
c:px(21, 31, MS.hi) c:px(22, 30, MS.hi)
local m2 = B.ell(38, 30, 6.6, 4, 0.5)
B.lit(c, m2, MS, 3)
c:fillMask(B.ell(38, 31, 4.6, 2.2, 0.5), "#ee8a3c")
c:fillMask(B.ell(37, 30, 2.4, 1.2, 0.5), "#ffb858") c:px(36, 30, "#fff4d6")
m2:edge():each(function(x, y) if y < 31 then c:px(x, y, MS.shade) end end)
-- steam question mark
D.stem(c, { {32,22}, {32,17}, {35,14}, {38,15}, {37,19}, {34,22} }, 1, "#e4f6ff", "#fff4d6")
c:px(34, 25, "#e4f6ff")
D.fin()
