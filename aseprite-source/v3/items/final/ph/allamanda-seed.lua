local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- allamanda-seed: flat round brown winged seeds with a papery rim, and a prickly capsule half, on a glossy whorled leaf scrap; sprout is a whorl of lanceolate leaves. quirk: a tiny milk-white sap bead on the capsule.
local c = D.new("allamanda-seed")
D.scrap(5, 55, 56, 50, 6.5, D.LEAF, {})
local WG = {"#5e3a2a","#7e5238","#a2704c","#c49468","#e0b88a","#f4d8ae"}
for _, s in ipairs{{16,52,5.2,4.4,0.2},{28,53,5,4.2,-0.1},{40,51,5,4.2,0.3}} do
  D.lit(D.ell(s[1], s[2], s[3], s[4], s[5]), WG, 3.2)
  D.ell(0,0,1,1)
  c:fillMask(D.ell(s[1], s[2], s[3]-2, s[4]-2, s[5]), "#6f4033") c:px(s[1]-1, s[2]-1, "#c49468")
end
-- capsule (spiky)
local cap = D.ell(51, 44, 4.4, 5.2, 0.2) D.lit(cap, {"#3f4a1c","#5e6c28","#80903a","#a0b050","#c0d070","#e0f098"}, 2.6)
for _, p in ipairs{{47,40},{46,44},{48,48},{54,40},{56,44},{54,49},{51,38},{51,50}} do c:px(p[1], p[2], "#3f4a1c") end
c:px(52,42,"#fff4d6") c:px(52,43,"#fff4d6")
-- sprout whorl
D.stem(28, 49, 28, 28, "#7aa860") D.stem(29, 49, 29, 28, "#5a8848")
for _, L in ipairs{{22,40,5,1.7,-0.5},{35,40,5,1.7,0.5},{22,33,5,1.7,-0.5},{35,33,5,1.7,0.5},{28,23,1.8,5,0}} do D.lf(L[1], L[2], L[3], L[4], L[5], D.LEAF2) end
D.fin()
