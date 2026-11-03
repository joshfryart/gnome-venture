local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- almond-butter: squat glass jar of grainy brown butter with a cream label, tin lid, and a wooden spoon dipped in with a drip. quirk: the butter has swirled into a little peak.
local c = D.new("almond-butter")
c:groundShadow(32, 57, 18, 2)
local glass = c:rrect(14, 24, 50, 56, 5)
D.lit(glass, {"#4a7a7c","#6aa0a0","#8ac4c0","#aae0d8","#c8f0e8","#e8fff8"}, 4, {nospec=true})
local BT = {"#4a2a1c","#6a3e26","#8a5634","#a8703e","#c8905a","#e8b27c"}
local fill = c:rrect(16, 30, 48, 55, 4)
D.lit(fill, BT, 4)
fill:each(function(x, y) if (x*5+y*3)%11==0 then c:px(x,y,BT[2]) elseif (x*3+y*7)%13==0 then c:px(x,y,BT[6]) end end)
-- swirl peak
D.lit(c:poly{{20,30},{26,24},{32,22},{38,25},{44,30}}, BT, 2)
c:px(32,20,BT[5]) c:px(31,21,BT[5]) c:px(32,21,BT[4]) c:px(33,21,BT[4])
-- label
D.lit(c:rrect(20, 38, 44, 52, 2), D.CRM, 2, {nospec=true})
c:fillMask(c:ellipse(32, 44, 4, 3), "#a8703e") c:px(30,43,"#e8b27c")
D.ln(23,49,41,49,"#c9a98a")
-- lid
D.lit(c:rrect(12, 16, 52, 25, 2), D.STEEL, 2)
for x = 16, 50, 3 do c:px(x, 20, "#4d5275") end
-- spoon
D.ln(46,4,40,22,"#864c33") D.ln(47,4,41,22,"#a35f3c") D.ln(48,4,42,22,"#c98a54")
D.lit(c:ellipse(39, 24, 3, 3.6), BT, 2)
c:px(53,32,"#a8703e") c:px(53,33,"#a8703e") c:px(53,34,"#8a5634")
D.fin()
