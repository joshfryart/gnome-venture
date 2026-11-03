local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- almond-seed: smooth teardrop almond kernels with a pale groove on a narrow serrated almond-leaf scrap; sprout has lance leaves with red petioles. quirk: one kernel is blanched, ivory, among the brown ones.
local c = D.new("almond-seed")
D.scrap(4, 53, 58, 50, 6.5, D.LEAF, {})
local KR = {"#4a2a1c","#6a3e26","#8a5634","#a8703e","#c8905a","#eab07c"}
for _, s in ipairs{{16,50,6.2,3.8,-0.3},{28,52,6,3.8,0.15}} do
  D.seed(s[1], s[2], s[3], s[4], s[5], KR) D.ln(floor(s[1]-s[3]+2), floor(s[2]+1), floor(s[1]+s[3]-2), floor(s[2]-1), KR[2])
end
D.seed(41, 50, 6, 3.8, 0.35, D.CRM) D.ln(36,52,46,49,"#c9a98a")
D.stem(28, 48, 28, 28, "#c8503e") D.stem(29, 48, 29, 28, "#8f3a3a")
for _, L in ipairs{{20,38,7,1.7,-0.6},{37,38,7,1.7,0.6},{22,30,6,1.5,-0.7},{35,30,6,1.5,0.7},{28,22,1.8,5.5,0}} do D.lf(L[1], L[2], L[3], L[4], L[5], D.LEAF2) end
D.fin()
