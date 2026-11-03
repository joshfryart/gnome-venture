local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-play: fat rounded green play triangle with a bright bevel.
-- quirk: a tiny sprout with two leaves pokes out of the tip as if the button is growing.
local c = D.new("ico-play")
local m = c:poly{ {17, 10}, {17, 54}, {55, 32} }
local sm = m:copy():shrink(2):grow(4):clip(c:poly{ {13, 6}, {13, 58}, {58, 32} })
D.lit(c, sm, D.GRN, 9, { amb = 0.06 })
-- inner bevel groove
for y = 19, 45 do local x0 = 24 c:px(x0, y, D.GRN[2]) end
D.ln(c, 24, 19, 47, 32, D.GRN[2]) D.ln(c, 24, 45, 47, 33, D.GRN[2])
D.pts(c, { {26, 21}, {27, 21}, {28, 22}, {26, 22} }, D.GRN[6])
-- sprout
D.ln(c, 56, 30, 56, 22, D.GRN[3]) D.ln(c, 57, 30, 57, 22, D.GRN[2])
D.leaf(c, 56, 24, 49, 16, 3, D.GRN, {})
D.leaf(c, 57, 22, 63, 15, 3, D.GRN, {})
D.fin()
