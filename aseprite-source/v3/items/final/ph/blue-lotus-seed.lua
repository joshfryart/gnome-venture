local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blue-lotus-seed")
-- blue-lotus-seed: two round dark-green lotus nuts on a round floating pad scrap; sprout has a rolled-up round pad and a tiny pad. quirk: a water droplet sits on the pad like a pearl.
D.E(32, 50, 25, 6, 0, D.LEAF2, 3)
D.ln(32, 50, 32, 45, "#bfe688") D.ln(32, 50, 14, 48, "#6ab455") D.ln(32, 50, 50, 48, "#6ab455") D.ln(32, 50, 20, 54, "#6ab455") D.ln(32, 50, 44, 54, "#6ab455")
local S = {"#10281e","#1c4a34","#2c6a46","#4a9060","#78b880","#b0dca4"}
D.seed(22, 50, 4.2, 4, 0, S) D.seed(34, 51, 4.4, 4.2, 0, S)
D.px(24, 50, "#ece0a0") D.px(36, 51, "#ece0a0")
D.stem2(40, 48, 40, 30)
D.E(40, 24, 7, 5, 0, D.SEA, 2.5) D.ln(40, 24, 40, 30, "#b4e8d0") D.ln(34, 22, 38, 24, "#b4e8d0") D.ln(46, 22, 42, 24, "#78c8b4")
D.E(49, 41, 3, 2, 0.2, D.LEAF2, 1.5)
D.E(48, 51, 2, 2, 0, D.SEA, 1) D.px(47, 50, "#fcfffa")
D.fin()
