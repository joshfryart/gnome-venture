local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blue-violet-seed")
-- blue-violet-seed: three tiny teardrop pale seeds with a white elaiosome tip on a heart-shaped violet leaf scrap; sprout is a small kidney heart leaf. quirk: an ant carries one seed away.
D.P({{32,56},{12,48},{9,38},{18,34},{26,38},{32,42},{38,38},{46,34},{55,38},{52,48}}, D.LEAF, 3)
D.ln(32, 55, 32, 42, "#bfe688") D.ln(32, 50, 20, 42, "#5a9a50") D.ln(32, 50, 44, 42, "#5a9a50")
local S = {"#3a2810","#5c4220","#80602c","#a8803c","#cca658","#ecd088"}
D.seed(22, 48, 3, 2, -0.5, S) D.px(19, 50, "#fff4d6") D.seed(33, 52, 3, 2, 0.3, S) D.px(36, 53, "#fff4d6") D.seed(43, 47, 3, 2, 0.8, S) D.px(46, 49, "#fff4d6")
D.px(26, 38, "#14100e") D.E(50, 54, 2, 1.4, 0, D.CHIT, 1) D.px(48, 53, "#14100e") D.px(52, 53, "#14100e") D.px(49, 56, "#14100e") D.px(51, 56, "#14100e")
D.stem2(30, 40, 30, 28)
D.P({{30,12},{37,13},{40,20},{34,28},{30,31},{26,28},{20,20},{23,13}}, D.LEAF2, 3)
D.ln(30, 14, 30, 30, "#bfe688") D.ln(30, 20, 36, 17, "#5a9a50") D.ln(30, 20, 24, 17, "#bfe688") D.px(26, 15, "#fff4d6")
D.fin()
