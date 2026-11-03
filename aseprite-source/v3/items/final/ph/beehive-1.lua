local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- beehive-1: a small straw skep of three rings on a plank stand, dark arched entrance, one bee. quirk: a single straw sticks up from the crown.
local c = D.new("beehive-1")
c:groundShadow(32, 57, 20, 2)
D.lit(c:rect(12, 50, 52, 55), D.BRN, 2.5) D.ln(13, 51, 51, 51, "#c98a54")
D.lit(c:rect(16, 55, 20, 57), D.BRN, 1.5) D.lit(c:rect(44, 55, 48, 57), D.BRN, 1.5)
local top = D.skep(32, 51, 3, 17, 11, 4)
c:fillMask(c:poly{ {28, 50}, {28, 46}, {30, 43}, {34, 43}, {36, 46}, {36, 50} }, "#2c1a1e")
D.ln(33, 17, 34, 11, "#c88a22") D.px(34, 10, "#eab32e")
D.bee(50, 24)
D.fin()
