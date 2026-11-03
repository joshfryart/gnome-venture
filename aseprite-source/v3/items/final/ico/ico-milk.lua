-- ico-milk first draft (Sonnet). quirk: a milk drip runs down the bottle lip and the label has a cow patch
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-milk")
local MK = D.WHITEISH
c:groundShadow(32, 57, 14, 2)
local body = c:rrect(18, 27, 45, 55, 6)
local neck = c:rrect(24, 14, 39, 30, 3)
D.lit(neck, MK, 3, { amb = .12 })
D.H.vcyl(c, body, MK, 18, 45)
-- glass rim shoulders: bright edge
for y = 29, 53 do c:px(20, y, "#ffffff" == nil and CR or "#fbfcff") end
-- milk fill level hint (bluish glass top)
D.fill(c:rect(25, 20, 38, 23), "#cfe0f6")
D.fill(c:rect(25, 20, 38, 20), "#fbfcff")
-- cap
local cap = c:rrect(22, 8, 41, 15, 2)
D.lit(cap, D.BLUE, 2)
D.fill(c:rect(24, 11, 39, 11), D.BLUE[3])
-- label with cow patch
local lab = c:rect(18, 36, 45, 48)
D.fill(lab, "#f6e6bf") D.fill(c:rect(18, 36, 45, 36), "#c9a98a") D.fill(c:rect(18, 48, 45, 48), "#c9a98a")
D.fill(c:ellipse(28, 41, 4, 3), INK) D.fill(c:ellipse(37, 44, 3, 2), INK)
D.fill(c:rect(24, 40, 25, 41), "#51302b")
c:px(26, 38, "#6f4033")
-- drip from cap/rim
D.fill(c:rect(40, 16, 41, 22), "#fbfcff") D.fill(c:rect(41, 23, 41, 25), "#eef2fb") c:px(41, 26, "#b8c4e4")
D.fin()
