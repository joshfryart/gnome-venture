local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("balloon-flower-seed")
-- balloon-flower-seed: flat glossy dark-brown seeds on a blue-green oval leaf scrap; the seedling has toothed lance leaves and a pale-blue inflated bud. quirk: the bud is drawn like a little balloon, tied with a thread to the stem.
D.scrap(6, 54, 54, 48, 8, {"#1c4a54","#2a6a66","#3f8a76","#5aaa84","#84c898","#b4e4b0"})
local S = {"#12100c","#241c14","#38281a","#503822","#6e4e2e","#90683c"}
D.seed(14, 50, 3.4, 2, 0.3, S) D.seed(22, 52, 3.4, 2, -0.2, S) D.seed(30, 49, 3.4, 2, 0.5, S) D.seed(24, 46, 3, 1.8, 0.1, S)
D.stem2(40, 48, 40, 24)
D.lf(35, 40, 4, 1.8, -0.5, D.LEAF) D.lf(45, 38, 4, 1.8, 0.5, D.LEAF) D.lf(36, 30, 3.4, 1.6, -0.6, D.LEAF2) D.lf(45, 29, 3.4, 1.6, 0.6, D.LEAF2)
-- balloon bud
D.E(40, 15, 6.5, 7.5, 0, {"#3a4a8a","#566ab4","#7a8ed4","#9aaee8","#c0d0f6","#e6efff"}, 5)
for _, a in ipairs{-0.6, 0, 0.6} do D.ln(40 + floor(a * 8), 10, 40 + floor(a * 4), 22, "#566ab4") end
D.P({{38,22},{42,22},{40,25}}, {"#2a5a2c","#3f7a38","#5a9a44","#7ab854","#a0d470","#cff09c"}, 1)
D.px(37, 11, "#fff4d6") D.px(37, 12, "#fff4d6")
D.fin()
