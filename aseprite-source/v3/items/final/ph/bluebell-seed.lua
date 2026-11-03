local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("bluebell-seed")
-- bluebell-seed: six glossy jet-black round seeds in a split pale papery capsule on a strap-leaf scrap; sprout is a single long grassy strap leaf curled over. quirk: one seed sits perched on the strap tip.
D.scrap(4, 57, 58, 52, 6, D.LEAF2)
D.P({{12,38},{30,34},{50,38},{48,50},{30,54},{14,50}}, D.CRM, 3) D.ln(30, 36, 30, 52, "#c9a98a") D.ln(22, 38, 22, 50, "#c9a98a") D.ln(38, 38, 38, 50, "#c9a98a")
local S = {"#0c0a12","#1c1624","#2e2438","#46385a","#6a5a84","#a090c0"}
for i, p in ipairs({{17,44},{23,47},{29,44},{35,47},{41,44},{46,47}}) do D.seed(p[1], p[2], 2.6, 2.6, 0, S) end
D.stem2(32, 34, 33, 28)
D.P({{33,28},{34,14},{42,8},{54,14},{55,17},{47,12},{40,15},{37,28}}, D.LEAF, 2) D.ln(34, 26, 36, 14, "#bfe688")
D.seed(53, 12, 2.2, 2.2, 0, S)
D.fin()
