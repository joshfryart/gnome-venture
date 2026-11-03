local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("apple-seed")
-- apple-seed: three glossy teardrop pips on a scrap of serrated apple leaf; a seedling with two fat cotyledons and a first oval leaf. quirk: one pip still has a sliver of white apple flesh on it.
D.scrap(8, 54, 52, 44, 8, D.LEAF2)
for i = 0, 6 do D.px(10 + i * 6, 46 + floor(i * 0.2) + (i % 2) * 8, "#173f36") end
local S = {"#2a140e","#4a2416","#6c3a1e","#8c5028","#ae6c38","#d09050"}
local function pip(x, y, ang) D.seed(x, y, 3.8, 2.4, ang, S) D.px(floor(x + 2.4 * cos(ang)), floor(y + 2.4 * sin(ang)), "#2a140e") end
pip(18, 50, -0.4) pip(30, 52, 0.3) local p3 = pip(41, 49, -0.1)
D.px(18, 51, "#fbf4d8") D.px(19, 51, "#ece0b0") D.px(17, 52, "#ece0b0")
D.stem2(41, 46, 41, 30)
D.cots(39, 31, 4, 2.2, D.LEAF2)
D.lf(41, 24, 2.6, 5, 0.1, D.LEAF) D.ln(41, 20, 41, 28, "#bfe688")
D.fin()
