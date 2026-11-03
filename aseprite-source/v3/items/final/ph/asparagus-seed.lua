local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("asparagus-seed")
-- asparagus-seed: three round black seeds and one red berry on a bit of feathery asparagus frond; the seedling is a single scaly spear with a first wisp of needles. quirk: a lone ripe berry is split open to show the seeds.
D.scrap(8, 54, 52, 50, 6, {"#2a5a2c","#3f7a38","#5a9a44","#7ab854","#a0d470","#cff09c"}, {norib=true})
for i = 0, 11 do local x = 10 + i * 4 D.ln(x, 51 - (i % 3), x + 2, 57, "#2a5a2c") D.px(x, 49, "#a0d470") end
local S = {"#0e0a12","#1c1620","#2c2430","#423846","#5c5062","#827890"}
D.seed(18, 50, 3.2, 3.2, 0, S) D.seed(26, 52, 3, 3, 0, S) D.seed(34, 49, 3.2, 3.2, 0, S)
-- split berry
D.E(46, 49, 5.5, 5.5, 0, D.RED, 3)
D.ln(46, 44, 46, 54, "#4a1630") D.E(44, 49, 1.5, 1.8, 0, S, 1) D.E(48, 49, 1.5, 1.8, 0, S, 1)
-- spear seedling
D.H.cyl(c, 34, 46, 35, 22, function(t) return 2.2 - t * 0.6 end, {"#2a5a2c","#3f7a38","#5a9a44","#7ab854","#a0d470","#cff09c"}, {})
for k = 0, 3 do D.px(33, 28 + k * 4, "#7a5a98") D.px(36, 30 + k * 4, "#5a3f78") end
D.E(35, 21, 1.8, 3, 0, {"#3a2a52","#5a3f78","#7a5a98","#8a9a58","#a8c070","#cce08c"}, 1)
D.ln(35, 28, 40, 24, "#a0d470") D.ln(34, 32, 29, 28, "#7ab854") D.ln(35, 36, 41, 34, "#a0d470")
D.fin()
