local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- almond: a pitted tan shell with a peeled brown kernel leaning on it, and a pink blossom on a twig. quirk: the kernel has a tiny nibble.
local c = D.new("almond")
c:groundShadow(32, 55, 20, 2)
D.ln(6,16,30,10,"#51302b") D.ln(6,17,30,11,"#864c33") D.ln(24,12,34,6,"#864c33")
-- blossom
local pts = {{10,10},{15,8},{14,14},{8,15},{6,10}}
for _, p in ipairs(pts) do D.lit(D.ell(p[1]+4, p[2]+2, 2.8, 2.8), D.PINK, 1.8) end
c:fillMask(c:rect(13,11,14,12), "#f5b82e")
D.lf(34, 12, 4, 1.5, -0.4, D.LEAF)
-- shell
local SH = {"#6a4a38","#8f6a46","#b88c5c","#d4aa74","#e8c894","#f6e2b8"}
D.lit(D.ell(24, 40, 13, 9, -0.35), SH, 5)
local shell = D.ell(24, 40, 13, 9, -0.35)
shell:each(function(x, y) if (x*7 + y*3) % 9 == 0 then c:px(x, y, SH[2]) elseif (x*5+y*11)%13==0 then c:px(x,y,SH[5]) end end)
D.ln(14,45,34,34,SH[2])
-- kernel
local KR = {"#3a2018","#5e3828","#86512f","#a8683a","#cc8a52","#eab07c"}
local k = D.ell(44, 42, 10, 6.5, 0.35) D.lit(k, KR, 4)
D.ln(36,42,52,48,KR[2])
D.ln(40,38,48,40,KR[6])
D.fin()
