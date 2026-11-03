local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- ackee: a red-orange pod split open in three, showing cream-yellow arils each capped on a glossy black seed. quirk: a drip of juice.
local c = D.new("ackee")
c:groundShadow(32, 56, 14, 2)
local ST = {"#3a2a24","#5e4630","#7e6a3c","#a09050","#c8b870","#e6d8a0"}
D.ln(32,6,32,12,"#5e4630") D.ln(33,6,33,12,"#7e6a3c") D.ln(31,5,34,5,"#a09050")
-- pod: lower body pear + three lobes opening
local body = c:ellipse(32, 38, 12, 14)
D.lit(body, D.RED, 5)
D.lit(c:poly{{20,34},{14,18},{22,12},{27,24},{28,34}}, D.ORG, 3)
D.lit(c:poly{{44,34},{50,18},{42,12},{37,24},{36,34}}, D.ORG, 3)
D.lit(c:poly{{26,30},{29,14},{35,14},{38,30}}, D.RED, 3)
local arils = {{24,22,3.8,5},{32,24,3.8,5.5},{40,22,3.8,5}}
for _, a in ipairs(arils) do
  local m = D.ell(a[1], a[2], a[3], a[4], 0) D.lit(m, D.YEL, 2.6)
  c:fillMask(D.ell(a[1], a[2]-5, 1.6, 1.6, 0), "#1c1418") c:px(a[1]-1, a[2]-6, "#6a5a66")
end
-- creased seams
for y = 30, 50 do c:px(32, y, "#a82c3c") end
c:px(24,52,"#6e2038") c:px(39,52,"#6e2038")
-- drip
c:px(46,40,"#ffe46e") c:px(46,41,"#ffe46e") c:px(46,42,"#f8d048") c:px(45,43,"#eab32e") c:px(46,43,"#f8d048") c:px(46,44,"#eab32e")
D.fin()
