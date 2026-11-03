local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- almond-peach-seed: a deeply grooved elongated hybrid stone with an almond kernel beside it, on a serrated lanceolate peach-leaf scrap; sprout is a peach seedling with willowy leaves. quirk: the stone is cracked and the kernel peeks out.
local c = D.new("almond-peach-seed")
D.scrap(5, 55, 57, 49, 7, D.LEAF2, {})
for i = 0, 10 do local x = 8 + i * 4.5 c:px(floor(x), 55 - floor(i*.55) - 6, "#9dd06c") c:px(floor(x)+1, 55 - floor(i*.55) + 6, "#173f36") end
local ST = {"#3a2018","#5e3828","#7e4e32","#a06a42","#c08a58","#dcac7c"}
local s = D.seed(22, 49, 8, 5, -0.2, ST)
s:each(function(x, y) if (x*3+y*5)%7==0 then c:px(x,y,ST[2]) end end)
D.ln(15,50,29,45,ST[1])
c:fillMask(c:ellipse(27,47,1.4,1.4), "#f6e6bf") c:px(27,46,"#fff4d6")
-- kernel
local KR = {"#4a2a1c","#6a3e26","#8a5634","#a8703e","#c8905a","#eab07c"}
D.seed(42, 50, 5, 3.2, 0.3, KR)
-- sprout
D.stem(22, 44, 22, 22, "#c08a58") D.stem(23, 44, 23, 22, "#8a5634")
for _, L in ipairs{{14,38,7,1.6,-0.5},{32,36,7,1.6,0.5},{15,28,6,1.5,-0.6},{31,26,6,1.5,0.6},{23,16,1.6,5.5,0}} do D.lf(L[1], L[2], L[3], L[4], L[5], D.LEAF2) end
D.fin()
