local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("avocado-seed")
-- avocado-seed: one big glossy brown avocado stone, split along its crown to show a pale shoot, three toothpicks in its belly, on a long glossy leaf scrap; the sprout has a pink-bronze young leaf. quirk: the stone is perched on toothpicks like it is waiting for a glass of water.
D.scrap(4, 56, 58, 50, 7, {"#173f36","#21593f","#2e7646","#45954c","#6ab455","#9dd06c"}, {norib=false})
-- toothpicks
D.ln(15, 34, 21, 36, "#d9b37c") D.ln(15, 35, 21, 37, "#a8845a") D.ln(37, 34, 43, 32, "#d9b37c") D.ln(37, 35, 43, 33, "#a8845a")
local S = {"#2a140e","#4a2416","#6c3a1e","#8c5028","#b06c38","#d89458"}
D.E(30, 42, 11, 12, 0, S, 7)
D.px(25, 35, "#fbe0b8") D.px(26, 35, "#fbe0b8") D.px(25, 36, "#f0c690")
-- split crown
D.ln(30, 31, 30, 36, "#2a140e") D.ln(29, 33, 29, 36, "#e8d890")
-- shoot
D.stem2(30, 31, 30, 18)
D.lf(25, 17, 5, 2.6, -0.5, {"#5a1c2a","#8a2c3a","#b44a4a","#d27060","#ec9878","#ffc49a"})
D.lf(35, 14, 5, 2.6, 0.5, {"#5a1c2a","#8a2c3a","#b44a4a","#d27060","#ec9878","#ffc49a"})
D.lf(30, 11, 2.2, 4, 0, D.LEAF2)
D.fin()
