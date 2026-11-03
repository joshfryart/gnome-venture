local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-star: plump gold five-point star, rounded arms, one bright pop.
-- quirk: a little cross-shaped bandage is stuck on its upper-right arm.
local c = D.new("ico-star")
local m = c:poly(D.starPts(32, 34, 27, 13, 5))
m:add(c:ellipse(32, 34, 13, 13))
D.lit(c, m, D.YEL, 12, { amb = 0.08 })
D.ln(c, 28, 26, 22, 20, D.YEL[6]) D.ln(c, 29, 22, 31, 14, D.YEL[5])
D.rect(c, 40, 30, 50, 34, D.CRM[4]) D.rect(c, 40, 34, 50, 34, D.CRM[1]) D.rect(c, 44, 30, 46, 34, D.CRM[2])
c:px(41, 31, D.CRM[6]) c:px(48, 32, D.CRM[2])
D.fin()
