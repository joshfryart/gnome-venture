-- candied-chestnuts (dB13 first draft)
local NAME = "candied-chestnuts"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB13.lua")
local B, HP, X, H = D.B, D.HP, D.X, D.H
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local WOOD = {"#3a2030","#51302b","#864c33","#b97a4a","#d49c62","#e8c08a"}
local STEEL = {"#2f3350","#444663","#74758c","#9a99ab","#c4c3d0","#e8e6ee"}
local GRN = {"#163a35","#1f553f","#2b7046","#3f8f4c","#62ad55","#93cb68"}
local SEEDBR = {"#3a1a1e","#62262a","#8c3c32","#b45c3c","#d68650","#f0b878"}
local CREAM = "#fff4d6"
local c = D.new(NAME)
local CH = {"#2a140e","#4a2210","#6e3414","#94501e","#b87030","#e0a058"}
local PP = {"#8f4a1f","#b8742a","#d99a3e","#f0b850","#ffd078","#ffe9a8"}
c:groundShadow(32,57,22,3)
-- paper cup, pleated
local cup = HP.mask() cup:add(c:poly{{12,38},{52,38},{47,56},{17,56}})
H.vcyl(c, cup, PP, 12, 52)
for x = 14, 50, 4 do B.ln(c, x, 39, x + (x < 32 and 1 or -1), 55, PP[2], cup) end
for x = 14, 50 do c:px(x, 38, PP[6]) end
-- glazed chestnuts
D.ball(c, 22, 32, 10, 9, CH, 0, 6) D.ball(c, 42, 33, 9, 8, CH, 0, 6) D.ball(c, 32, 22, 10, 9, CH, 0, 6)
-- glaze shine + sugar crystals
c:fillMask(c:rect(26,15,29,15), "#fff4d6") c:px(18,28,"#fff4d6") c:px(19,28,"#fff4d6") c:px(38,29,"#fff4d6")
for _, p in ipairs{{30,26},{24,35},{40,38},{35,19},{46,30}} do c:px(p[1],p[2],"#ffe9a8") end
-- pointy tip of chestnut
c:px(32,12,"#e0a058") c:px(32,13,"#94501e")
-- drip of syrup (quirk)
B.ln(c, 28, 31, 28, 37, "#ffc860") c:px(28,38,"#ffe9a8")
D.fin()
