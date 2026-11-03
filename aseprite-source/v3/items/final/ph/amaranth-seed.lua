local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- amaranth-seed: tiny glossy lens-shaped cream-black seeds on a red-veined diamond leaf scrap; sprout has two lanceolate seed leaves on a magenta stem. quirk: a magenta tassel sprig lies across the leaf.
local c = D.new("amaranth-seed")
local m = D.scrap(5, 54, 57, 50, 7.5, D.LEAF2, {})
D.ln(10,54,54,50,"#a82c3c")
for _, p in ipairs{{20,54,24,58},{20,54,25,50},{32,53,36,57},{32,53,36,49},{44,51,48,55},{44,51,48,47}} do end
for _, v in ipairs{{20,53,23,57},{20,53,23,50},{32,52,35,56},{32,52,35,48},{43,51,46,55},{43,51,46,47}} do D.ln(v[1],v[2],v[3],v[4],"#a82c3c") end
local SD = {"#1c1418","#3a2a2c","#5e4a42","#8a7260","#bca280","#eadcb4"}
for _, s in ipairs{{18,51,3.2,2.2,0.2},{25,49,3,2.1,-0.3},{32,52,3.2,2.2,0.1},{39,50,3,2.1,0.4},{46,48,3,2.1,-0.2},{29,55,2.8,2,0}} do D.seed(s[1], s[2], s[3], s[4], s[5], SD) end
c:fillMask(c:rect(31,53,33,53), "#bca280")
-- sprout
D.stem(32, 47, 32, 26, "#ee78b4") D.stem(33, 47, 33, 26, "#a82c7a")
D.lf(25, 25, 6, 2.2, -0.45, D.LEAF) D.lf(40, 25, 6, 2.2, 0.45, D.LEAF)
D.lf(32, 20, 2.4, 3.6, 0, D.LEAF2)
-- tassel sprig
local MG = {"#4a1040","#7a1c5e","#a82c7a","#d04a96","#ee78b4","#ffa8d0"}
D.lit(D.ell(11, 41, 2.2, 5, -0.2), MG, 1.8)
D.fin()
