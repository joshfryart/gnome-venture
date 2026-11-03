local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blood-lily-seed")
-- blood-lily-seed: three fat orange-red berry seeds on a strap-leaf scrap; sprout is a ribbed strap leaf pair. quirk: a seed has a pale hilum shaped like a smile.
D.scrap(5, 50, 58, 54, 7, D.LEAF2)
local S = {"#5a1210","#8c2018","#bc3424","#e05030","#f08050","#ffb078"}
D.seed(18, 50, 4.4, 4.4, 0, S) D.seed(30, 52, 4.6, 4.6, 0, S) D.seed(42, 50, 4.2, 4.2, 0, S)
D.ln(28, 55, 32, 55, "#fbe8c0") D.px(27, 54, "#fbe8c0") D.px(33, 54, "#fbe8c0")
D.stem2(44, 46, 44, 40)
D.lf(42, 24, 2, 14, -0.15, D.LEAF) D.lf(48, 28, 2, 11, 0.3, D.LEAF2)
D.ln(42, 12, 42, 36, "#bfe688") D.ln(48, 18, 48, 36, "#bfe688")
D.fin()
