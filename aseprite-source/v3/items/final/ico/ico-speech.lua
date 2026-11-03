local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-speech: chunky rounded speech bubble with a tail at the lower left and three typing dots.
-- quirk: the three dots grow in size, the biggest one is nearly spilling out of the bubble.
local c = D.new("ico-speech")
local b = c:rrect(7, 9, 57, 42, 8):add(c:poly{ {12,38},{26,38},{14,56} })
D.lit(c, b, D.BLU, 10, { amb = 0.08 })
D.rect(c, 14, 12, 50, 13, D.BLU[5]) c:px(10, 17, D.BLU[5]) c:px(10, 18, D.BLU[5])
D.rect(c, 12, 38, 22, 39, D.BLU[2])
D.ln(c, 15, 41, 14, 52, D.BLU[2])
local function dot(x, y, r) c:fillMask(c:ellipse(x, y, r, r), D.CRM[5]) c:px(x - 1, y - 1, D.CRM[6]) D.rect(c, x - r + 1, y + r, x + r - 1, y + r, D.CRM[2]) end
dot(18, 26, 2) dot(30, 26, 3) dot(44, 25, 4)
D.fin()
