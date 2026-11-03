local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-sparkle: a big four-point glitter star with a smaller twin and a cream plus.
-- quirk: the big star's lower arm is a hair longer and curls into a tiny gold tail.
local c = D.new("ico-sparkle")
local big = c:poly{ {28,6},{33,25},{52,30},{33,35},{29,50},{25,35},{6,30},{25,25} }
D.lit(c, big, D.YEL, 12, { amb = 0.08 })
D.ln(c, 28, 10, 28, 24, D.YEL[6]) D.ln(c, 10, 30, 24, 30, D.YEL[5])
D.rect(c, 29, 30, 33, 34, D.YEL[2])
D.rect(c, 27, 28, 29, 30, D.CREAM)
-- curl tail
D.rect(c, 28, 50, 29, 55, D.YEL[3]) D.rect(c, 29, 55, 32, 56, D.YEL[3]) D.rect(c, 32, 53, 33, 56, D.YEL[2]) D.rect(c, 30, 52, 31, 53, D.YEL[2])
local sm = c:poly{ {50,8},{53,15},{60,18},{53,21},{50,28},{47,21},{40,18},{47,15} }
D.lit(c, sm, D.ORG, 6, { amb = 0.1 })
D.ln(c, 50, 11, 50, 15, D.ORG[6]) c:px(48, 17, D.ORG[6]) c:px(49, 17, D.ORG[6])
c:sparkle(14, 50)
D.fin()
