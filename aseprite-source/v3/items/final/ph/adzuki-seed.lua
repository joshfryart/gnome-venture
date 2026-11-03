local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- adzuki-seed: red beans with a white hilum stripe on a trifoliate leaf scrap; sprout has two heart leaves and a trifoliate. quirk: a bean peeks out of a tiny cracked pod end.
local c = D.new("adzuki-seed")
local RB = {"#3a0c1a","#5e1426","#8a2030","#aa3038","#c84a48","#e8786c"}
D.scrap(6, 55, 56, 50, 7.5, D.LEAF2, {})
for _, s in ipairs{{18,51,4.4,3.2,0.2},{30,53,4.6,3.3,-0.25},{42,50,4.4,3.2,0.35}} do
  D.seed(s[1], s[2], s[3], s[4], s[5], RB)
  for k = -1, 1 do c:px(floor(s[1]+k+.5), floor(s[2]+1.2), "#f6e6bf") end
end
-- sprout from middle seed
D.stem(30, 49, 30, 31, "#a8c27a") D.stem(31, 49, 31, 31, "#7c9a58")
D.lf(24, 40, 4.2, 3, -0.5, D.LEAF) D.lf(37, 40, 4.2, 3, 0.5, D.LEAF)
D.stem(30, 31, 30, 26, "#7c9a58")
D.lf(30, 22, 3.2, 4, 0, D.LEAF2) D.lf(25, 26, 3.6, 2.6, -0.8, D.LEAF2) D.lf(36, 26, 3.6, 2.6, 0.8, D.LEAF2)
for k = 0, 3 do c:px(30, 19+k*2, "#bfe688") end
-- pod end
D.lit(D.ell(51, 40, 2.2, 5, 0.3), D.TAN, 1.8) c:px(51,38,"#8a2030") c:px(52,38,"#c84a48")
D.fin()
