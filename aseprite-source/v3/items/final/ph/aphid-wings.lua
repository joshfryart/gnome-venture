local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local c = D.new("aphid-wings")
-- aphid-wings: a pair of glassy shed wings crossed like a V, pale core, darker rim, veins and a dark pterostigma spot. quirk: a drop of honeydew sags from the joint.
local G = D.GLASS
local W1 = D.E(24, 26, 15, 7, 0.95, G, 3)
local W2 = D.E(40, 26, 15, 7, -0.95, G, 3)
-- veins
D.ln(31, 40, 19, 14, "#5a8aa0") D.ln(33, 40, 45, 14, "#5a8aa0") D.ln(30, 36, 24, 22, "#86b8c8") D.ln(34, 36, 40, 22, "#86b8c8")
D.ln(18, 22, 25, 20, "#86b8c8") D.ln(46, 22, 39, 20, "#86b8c8")
-- spots
D.E(20, 16, 1.2, 2, 0.4, D.SEED, 1) D.E(44, 16, 1.2, 2, -0.4, D.SEED, 1)
-- joint
D.E(32, 44, 3.2, 2.4, 0, D.LEAF, 1.5)
-- honeydew
D.ln(32, 46, 32, 50, "#e8a828") D.E(32, 53, 2.4, 3, 0, D.YEL, 1.5)
D.px(31, 52, "#fff4d6")
D.px(17, 12, "#ffffff" and "#fff4d6") D.px(18, 12, "#fff4d6")
D.fin()
