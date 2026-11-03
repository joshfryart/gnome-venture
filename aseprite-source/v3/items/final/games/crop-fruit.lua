local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- crop-fruit: round red apple, twin-lobed shoulders, dimpled crown, stem + leaf, waxy streak, cool bounce light.
-- quirk: a pink worm pokes out of a hole on the right cheek.
local c = D.new("crop-fruit")
local RED = { "#5a1c34", "#a52e40", "#d23c3c", "#e8553f", "#f77a4c", "#ffb080" }
c:groundShadow(32, 56, 15, 2)
local m = c:ellipse(25.5, 38, 11, 13):add(c:ellipse(38.5, 38, 11, 13)):add(c:ellipse(32, 41, 13, 12))
m:cut(c:ellipse(32, 25, 3, 2))
local idx = D.lit(c, m, RED, 7, { amb = 0.05, wrap = 0.2 })
-- dimple shading
for x = 29, 35 do D.shift(c, x, 27, RED, -2) end
-- stem and leaf
c:part(c:line({ {32, 27}, {33, 19}, {36, 12} }, 2), "wood", { band = 1 })
D.leaf(c, 36, 18, 53, 10, 5, "moss", { 4, 8 })
-- bounce light lower-right edge
m:edge():each(function(x, y) if x > 38 and y > 46 then c:px(x, y, "#c0506a") end end)
-- waxy specular streak
for _, p in ipairs{ {19, 33}, {19, 34}, {20, 32}, {21, 31} } do c:px(p[1], p[2], "#ffe8c8") end
c:px(19, 33, CREAM)
-- worm hole + worm
c:fillMask(c:ellipse(42, 44, 2, 1), "#3a1226")
local wm = D.sweep({ {42, 44}, {44, 37}, {50, 39}, {49, 33} }, function(t) return 1.3 end, 40)
wm:cut(c:ellipse(42, 44, 2, 1))
D.lit(c, wm, "petal", 1.5)
c:px(49, 33, INK) c:px(50, 32, "#fff4d6")
c:px(47, 38, "#c94f84") c:px(46, 39, "#c94f84")
c:fillMask(c:rect(40, 45, 44, 45), "#3a1226")
D.fin()
