local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- african-tulip-tree-seed: flat round papery winged seeds (pale membrane, dark brown centre) on a pinnate leaf scrap; sprout is a pair of oval-leaflet seedling leaves. quirk: a seed is mid-spin with a motion tick.
local c = D.new("african-tulip-tree-seed")
D.scrap(5, 54, 56, 49, 8, D.LEAF, {})
local MEM = {"#a08a68","#c4aa84","#e0cca0","#f0e0b8","#f8eed0","#fffaea"}
local CORE = {"#2e1c1c","#4a2a24","#6a4030","#8a5a40","#aa7852","#c89c70"}
for _, s in ipairs{{18,50,8,5,-0.1},{37,51,8.5,5.2,0.12},{50,47,6,4,0.4}} do
  local wing = D.ell(s[1], s[2], s[3], s[4], s[5]) D.lit(wing, MEM, 3.5)
  D.seed(s[1], s[2], 2.8, 2.4, s[5], CORE)
  for k = 1, 3 do local a = s[5] + 0.6 * k D.ln(s[1]+cos(a)*3.5, s[2]+sin(a)*3, s[1]+cos(a)*(s[3]-1.5), s[2]+sin(a)*(s[4]-1), "#c4aa84") end
end
D.stem(37, 46, 37, 30, "#86b86c") D.stem(38, 46, 38, 30, "#6a9a58")
for _, L in ipairs{{30,41,4.5,2.6,-0.4},{45,41,4.5,2.6,0.4},{31,34,4,2.4,-0.5},{44,34,4,2.4,0.5},{37,26,2.8,4.2,0}} do D.lf(L[1], L[2], L[3], L[4], L[5], D.LEAF2) end
c:px(53,40,"#fff4d6") c:px(55,38,"#fff4d6") c:px(56,41,"#fff4d6")
D.fin()
