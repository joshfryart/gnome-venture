local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- almond-peach: a blushing fuzzy peach with a cut-away quarter showing the long almond-shaped stone and creamy flesh; one leaf. quirk: the almond kernel pokes out of the stone like a nose.
local c = D.new("almond-peach")
c:groundShadow(32, 56, 17, 2)
local PCH = {"#9a3a3a","#c85a4a","#ee7e58","#ffa066","#ffc486","#ffe4b0"}
local body = c:ellipse(30, 36, 17, 17)
D.lit(body, PCH, 6)
body:each(function(x,y) if x > 38 and (x+y)%5==0 and body:has(x+1,y) then c:px(x,y,"#c85a4a") end end)
-- cut-away wedge
local wedge = c:poly{{30,36},{52,24},{52,52},{40,54}}:clip(body)
D.lit(wedge, {"#d89a4a","#eebb60","#f8d880","#fce8a0","#fff2c0","#fffae0"}, 4, {nospec=true})
D.ln(30,36,52,24,"#c85a4a") D.ln(30,36,40,54,"#c85a4a")
-- stone
local st = D.ell(40, 40, 9, 5.2, 0.6) D.lit(st, {"#4a2a1c","#6a3e26","#8a5634","#a8703e","#c8905a","#e0b078"}, 3)
D.ln(34,35,45,44,"#4a2a1c")
-- kernel nose
local kn = D.ell(47, 45, 3, 2, 0.6) D.lit(kn, D.CRM, 1.6)
-- crease + leaf + stem
D.ln(30,20,30,26,"#c85a4a")
D.ln(30,16,32,22,"#51302b") D.ln(31,16,33,22,"#864c33")
D.lf(40, 14, 8, 2.8, -0.45, D.LEAF2)
D.fin()
