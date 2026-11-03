local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local c = D.new("apple")
-- apple: round red apple with a stem dimple, yellow streaks, leaf and a waxy specular. quirk: a tiny worm peeks out of a hole on the lower right.
D.shadow(32, 56, 14, 2.5)
local m = c:ellipse(32, 35, 17, 16):add(c:ellipse(25, 31, 10, 11)):add(c:ellipse(40, 31, 10, 11))
m:cut(c:ellipse(32, 20, 4, 3))
D.lit(m, D.RED, 7)
-- yellow streaks
for i = 0, 5 do D.px(22 + i, 22 - (i % 2), "#f0a050") D.px(38 + i, 22 + (i % 2), "#f0a050") end
D.ln(20, 36, 22, 44, "#ee6a50") D.ln(28, 48, 33, 50, "#a82c3c")
-- stem
D.ln(32, 22, 33, 13, "#51302b") D.ln(33, 22, 34, 13, "#864c33")
-- leaf
D.scrap(35, 17, 49, 8, 4, D.LEAF)
-- wax specular
D.px(22, 29, "#fff4d6") D.px(23, 29, "#fff4d6") D.px(22, 30, "#fff4d6") D.px(21, 32, "#ff9a78")
-- worm hole and worm
D.E(42, 44, 2.6, 2.2, 0, {"#1c0c14","#2a1018","#3a1820","#4a1c24","#5a2028","#6e2038"}, 1)
D.ln(42, 43, 45, 38, "#d8d878") D.ln(43, 43, 46, 38, "#b8b858") D.E(46, 38, 1.8, 1.8, 0, D.YEL, 1)
D.px(46, 37, D.INK)
D.fin()
