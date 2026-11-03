local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- amber-lamppost: slim iron post with a scroll bracket and a faceted amber glass lantern, stepped base, a pale ring of glow. quirk: a moth circles the lantern.
local c = D.new("amber-lamppost")
local IR = {"#1c1a26","#2c2a3c","#404058","#585874","#78789a","#9c9cc0"}
local AM = {"#8f3a1f","#c25a24","#e88a2e","#ffb23c","#ffd060","#fff0a0"}
c:groundShadow(32, 58, 12, 2)
D.lit(c:rrect(22, 52, 42, 57, 1), IR, 2)
D.lit(c:rrect(26, 46, 38, 52, 1), IR, 2)
-- post
D.lit(c:rect(30, 20, 34, 46), IR, 2)
for y = 26, 44, 6 do D.lit(c:rect(29, y, 35, y+1), IR, 1) end
-- bracket scroll
D.ln(34,36,42,34,IR[4]) D.ln(42,34,44,38,IR[4]) D.ln(44,38,42,40,IR[4]) D.ln(30,36,22,34,IR[4]) D.ln(22,34,20,38,IR[4]) D.ln(20,38,22,40,IR[4])
-- lantern
D.lit(c:poly{{24,20},{40,20},{44,8},{20,8}}:clip(c:rect(0,8,63,20)), AM, 4)
D.lit(c:rect(21, 8, 43, 20), AM, 4)
D.ln(32,8,32,20,AM[2]) D.ln(26,8,26,20,AM[2]) D.ln(38,8,38,20,AM[2])
c:fillMask(c:rect(22,9,24,12), AM[6]) c:px(22,13,AM[6])
-- cap and top finial
D.lit(c:poly{{18,8},{46,8},{40,2},{24,2}}, IR, 2)
D.lit(c:rect(30, 0, 34, 2), IR, 1)
-- glow ring dots
for _, p in ipairs{{14,14},{50,14},{12,20},{52,20}} do c:px(p[1], p[2], AM[6]) end
-- moth
c:px(50,26,"#c9b2f0") c:px(51,26,"#c9b2f0") c:px(52,26,"#8a6fd0") c:px(53,26,"#8a6fd0") c:px(51,27,"#2b1c26") c:px(52,27,"#2b1c26") c:px(51,25,"#fff4d6")
D.fin()
