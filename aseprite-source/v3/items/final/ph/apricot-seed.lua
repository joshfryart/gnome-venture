local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("apricot-seed")
-- apricot-seed: flat pitted apricot stones, one cracked to show the pale almond-like kernel, on a scrap of heart-shaped apricot leaf; a seedling with two cotyledons and a pointed first leaf. quirk: a bite of orange flesh is still stuck to the smallest stone.
D.scrap(6, 56, 40, 40, 9, D.LEAF)
local S = {"#4a2c1c","#6e4228","#8e5c34","#b08046","#c89c60","#e0bc84"}
D.seed(16, 48, 5, 3.5, -0.5, S) D.seed(28, 51, 5.4, 3.8, 0.2, S)
-- groove ridge
D.ln(12, 51, 20, 45, "#4a2c1c") D.ln(24, 53, 33, 50, "#4a2c1c")
for i = 0, 4 do D.px(14 + i * 2, 50 - i, "#6e4228") D.px(26 + i * 2, 53 - floor(i/2), "#6e4228") end
-- cracked stone with kernel
D.seed(44, 52, 6, 4, 0.1, S)
D.E(44, 52, 3.4, 1.6, 0.1, {"#c0a070","#d8bc8c","#ecd8aa","#f6e8c0","#fbf0d0","#fffae8"}, 1)
D.ln(38, 52, 50, 52, "#2a1810")
-- flesh scrap
D.E(14, 52, 1.6, 1.2, 0, D.ORG, 1)
-- seedling from the middle stone
D.stem2(28, 47, 29, 28)
D.cots(27, 32, 4, 2, D.LEAF2)
D.P({{29,28},{24,22},{29,12},{34,22}}, D.LEAF, 2) D.ln(29, 14, 29, 26, "#bfe688")
D.fin()
