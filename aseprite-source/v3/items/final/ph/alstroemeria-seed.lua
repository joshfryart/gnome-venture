local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- alstroemeria-seed: round beige seeds popping from a three-valve split capsule, on a twisted lanceolate leaf scrap; sprout is a twisting pair of blades. quirk: the capsule valves curl like petals.
local c = D.new("alstroemeria-seed")
D.scrap(5, 55, 57, 50, 6.5, D.LEAF, {})
local SD = {"#6a4a38","#8f6a46","#b8905e","#d8b484","#ecd0a4","#faeac8"}
for _, s in ipairs{{16,52,3.6,3.6},{25,54,3.6,3.6},{34,52,3.4,3.4}} do D.seed(s[1], s[2], s[3], s[4], 0, SD) c:px(floor(s[1]), floor(s[2]), SD[2]) end
-- capsule
local CV = {"#3a4a1c","#566c28","#76903a","#98b44e","#bcd472","#e0f2a0"}
D.lit(c:poly{{46,52},{42,34},{46,28},{49,40},{49,52}}, CV, 2)
D.lit(c:poly{{49,52},{52,40},{57,30},{58,40},{54,52}}, CV, 2)
D.lit(c:poly{{43,36},{38,32},{40,26},{45,30}}, CV, 2)
c:fillMask(c:rect(48,38,49,50), "#3a4a1c")
c:px(45,34,SD[5]) c:px(52,36,SD[5])
-- sprout, twisted blades
D.stem(25, 49, 25, 30, "#7aa860") D.stem(26, 49, 26, 30, "#5a8848")
local function sblade(pts) for i = 1, #pts - 1 do B.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], "#3f8a4e") B.ln(c, pts[i][1]+1, pts[i][2], pts[i+1][1]+1, pts[i+1][2], "#5aaa58") end end
sblade{{25,34},{18,30},{16,24},{20,18}} sblade{{26,34},{32,28},{30,22},{34,16}}
D.lf(18, 17, 2.2, 3.6, 0.5, D.LEAF2) D.lf(34, 14, 2.2, 3.6, -0.5, D.LEAF2)
D.fin()
