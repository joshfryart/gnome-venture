local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-person: friendly bust, round head with a brown bob, blue jumper, rosy cheeks and a lit button nose.
-- quirk: a small leaf is tucked into the hair above the ear.
local c = D.new("ico-person")
local HAIR = { "#1e1218", "#3a2030", "#5a3426", "#7a4a34", "#9a6444", "#bb8460" }
local body = c:ellipse(32, 62, 22, 14):clip(c:rect(0, 0, 63, 57))
D.lit(c, body, D.BLU, 8, { amb = 0.1 })
D.rect(c, 28, 44, 36, 50, D.SKIN[2])
local hairBack = c:ellipse(32, 29, 17, 18)
D.lit(c, hairBack, HAIR, 8)
local face = c:ellipse(32, 33, 13, 13)
D.lit(c, face, D.SKIN, 9, { amb = 0.08 })
local fringe = c:poly{ {18, 27}, {20, 18}, {44, 18}, {46, 27}, {40, 24}, {33, 28}, {26, 24} }
D.lit(c, fringe:clip(c:ellipse(32, 29, 17, 18)), HAIR, 4)
c:eyeSmall(25, 31) c:eyeSmall(37, 31)
c:cheek(22, 38) c:cheek(40, 38)
c:fillMask(c:ellipse(31.5, 36, 2, 2), D.SKIN[3]) c:px(31, 35, D.SKIN[6]) c:px(31, 38, D.SKIN[1]) c:px(32, 38, D.SKIN[1])
D.pts(c, { {28, 41}, {29, 42}, {30, 42}, {31, 42}, {32, 42}, {33, 41} }, D.SKIN[1])
D.leaf(c, 18, 24, 11, 17, 3, D.GRN, {})
D.fin()
