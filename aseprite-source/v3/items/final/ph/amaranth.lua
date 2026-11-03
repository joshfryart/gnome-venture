local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- amaranth: tall drooping magenta tassel of tiny flowers on a red-green stem with diamond leaves and a little seed-pod side spike. quirk: a snail climbs the stem.
local c = D.new("amaranth")
local MG = {"#4a1040","#7a1c5e","#a82c7a","#d04a96","#ee78b4","#ffa8d0"}
D.ln(32,56,32,26,"#6a3a4a") D.ln(33,56,33,26,"#a85a5a") D.ln(31,56,31,30,"#4a2a38")
-- drooping plume: swept from top then curls down
local pl = H.sweep({{32,8},{44,4},{50,22},{44,44}}, function(t) return 4.2 - 2.2*t end, 80)
D.lit(pl, MG, 3.4)
pl:each(function(x, y) if (x*3+y*7)%5==0 then c:px(x,y,MG[6]) elseif (x+y*2)%7==0 then c:px(x,y,MG[2]) end end)
D.ln(33,28,40,12,"#a85a5a")
-- side spike
local sp = H.sweep({{32,36},{24,34},{18,38},{16,48}}, function(t) return 2.4 - 1.2*t end, 50)
D.lit(sp, MG, 2.4)
-- leaves
D.lf(24, 50, 6, 3.2, -0.7, D.LEAF) D.lf(41, 46, 6, 3.2, 0.7, D.LEAF2)
D.ln(20,53,28,47,"#bfe688") D.ln(45,43,37,49,"#bfe688")
-- snail
c:fillMask(c:ellipse(30,40,2.6,2.6), "#d9a070") c:fillMask(c:ellipse(30,40,1.4,1.4), "#864c33") c:px(29,39,"#fff4d6")
D.lit(c:rect(33,41,37,42), {"#8a6a5a","#c9a98a","#d9b88a","#e6cfa8","#f6e6bf","#fffbe8"}, 1) c:px(37,40,"#2b1c26") c:px(36,39,"#c9a98a")
D.fin()
