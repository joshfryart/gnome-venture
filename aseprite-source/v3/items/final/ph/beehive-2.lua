local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- beehive-2: a four-ring straw skep on a plank stand with a flag on a pin and two bees. quirk: a little red flag flies off a pin at the crown.
local c = D.new("beehive-2")
c:groundShadow(32, 57, 20, 2)
D.lit(c:rect(12, 50, 52, 55), D.BRN, 2.5) D.ln(13, 51, 51, 51, "#c98a54")
D.lit(c:rect(16, 55, 20, 57), D.BRN, 1.5) D.lit(c:rect(44, 55, 48, 57), D.BRN, 1.5)
D.skep(32, 51, 4, 16, 9, 3)
c:fillMask(c:poly{ {28, 50}, {28, 46}, {30, 43}, {34, 43}, {36, 46}, {36, 50} }, "#2c1a1e")
D.ln(32, 8, 32, 17, "#51302b") D.lit(c:poly{ {33, 8}, {41, 10}, {33, 13} }, D.RED, 1.5)
D.bee(51, 22) D.bee(13, 30)
D.fin()
