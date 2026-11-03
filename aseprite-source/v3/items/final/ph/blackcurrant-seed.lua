local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blackcurrant-seed")
-- blackcurrant-seed: a cluster of tiny flat brown currant seeds on a lobed blackcurrant leaf scrap; sprout with a 3-lobed serrated leaf. quirk: one seed still wears a shred of purple-black skin.
D.scrap(8, 52, 54, 56, 8, D.LEAF2)
local S = {"#2a1608","#4a2a12","#6a4220","#8a5c30","#aa7c44","#cca064"}
for i, p in ipairs({{16,52,0.5},{24,55,-0.6},{32,52,0.2},{41,55,-0.3},{49,52,0.7}}) do D.seed(p[1], p[2], 3.2, 2, p[3], S) D.ln(p[1]-1, p[2], p[1]+1, p[2], S[2]) end
D.E(32, 52, 3.2, 2, 0.2, D.JAM, 1.2) D.px(31, 51, "#e8c8e8")
D.stem2(30, 48, 30, 34)
D.E(30, 24, 3, 8, 0, D.LEAF, 2.5) D.E(22, 29, 6, 3, -0.6, D.LEAF, 2) D.E(38, 29, 6, 3, 0.6, D.LEAF, 2)
D.ln(30, 17, 30, 34, "#bfe688") D.ln(30, 30, 24, 26, "#bfe688") D.ln(31, 30, 37, 26, "#5a9a50")
for _, x in ipairs{17,19,41,43} do D.px(x, 31, "#173f36") end
D.fin()
