-- cherry-jam (v3 first draft, dB15). quirk: a sticky drip runs down the jar's side
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cherry-jam")
D.shadow(c, 32, 55, 19, 3)
local JAM = { "#3a0e24", "#6a1a34", "#9a2a40", "#c03a48", "#e05858", "#ff9a90" }
local jar = c:rrect(14, 20, 50, 54, 6)
H.vcyl(c, jar, JAM, 14, 50)
-- glass rim + shine
for y = 26, 48 do c:px(16, y, "#e8b0b0") end
c:px(17, 30, "#fff4d6") c:px(17, 31, "#fff4d6")
-- label
local lab = c:rrect(22, 34, 42, 47, 2)
H.lit(c, lab, { "#c8b890", "#e0d4ae", "#f0e6c8", "#f8f0d8", "#fffaea", "#fff8e8" }, { R = 2 })
H.lit(c, B.ell(32, 42, 3, 3, 0), "ember", { R = 2 })
B.ln(c, 33, 38, 35, 37, "#3f9150")
-- cloth lid, rope
local lid = c:poly{ {12, 14}, {52, 14}, {53, 25}, {49, 22}, {44, 26}, {38, 22}, {32, 26}, {26, 22}, {20, 26}, {15, 22}, {11, 25} }
H.lit(c, lid, "dusk", { R = 3 })
for x = 15, 49, 4 do B.ln(c, x, 15, x - 2, 22, "#5a459e", lid) end
B.ln(c, 13, 24, 51, 24, "#c9a46a") B.ln(c, 14, 25, 50, 25, "#864c33")
-- drip
B.ln(c, 46, 27, 46, 40, "#e05858") B.ln(c, 47, 27, 47, 38, "#c03a48")
H.lit(c, c:ellipse(46, 42, 1.5, 2.2), JAM, { R = 1 })
D.fin()
