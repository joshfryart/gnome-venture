local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- beehive-3: a tall five-ring straw skep on a stand with a knob finial, a honey drip from the entrance, three bees. quirk: honey oozes from the hive door and pools on the plank.
local c = D.new("beehive-3")
c:groundShadow(32, 58, 21, 2)
D.lit(c:rect(10, 52, 54, 57), D.BRN, 2.5) D.ln(11, 53, 53, 53, "#c98a54")
D.skep(32, 53, 5, 17, 9, 3)
c:fillMask(c:poly{ {28, 52}, {28, 48}, {30, 45}, {34, 45}, {36, 48}, {36, 52} }, "#2c1a1e")
D.lit(D.ell(32, 8, 3, 3, 0), D.GRAIN, 1.8) D.ln(32, 9, 32, 12, "#51302b")
for _, y in ipairs{46, 49, 52} do D.px(38, y, "#ffbc5c") end D.px(38, 53, "#ff9a3c") D.px(37, 54, "#ffbc5c") D.px(38, 54, "#ff9a3c") D.px(39, 54, "#ffbc5c")
D.bee(52, 20) D.bee(12, 26) D.bee(50, 40)
D.fin()
