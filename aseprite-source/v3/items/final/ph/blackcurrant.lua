local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blackcurrant")
-- blackcurrant: a slim sprig with a strig of five glossy blue-black currants (flower-end star tuft) hanging from a lobed leaf. quirk: one currant is still green-red unripe.
D.stem2(30, 6, 30, 14)
D.P({{30,8},{40,4},{50,8},{48,16},{40,16},{36,12}}, D.LEAF, 2.5) D.ln(32, 9, 48, 9, "#bfe688") D.ln(40, 8, 42, 14, "#5a9a50")
D.ln(30, 14, 28, 22, "#a85c48") D.ln(28, 22, 22, 30, "#a85c48") D.ln(28, 22, 36, 30, "#a85c48") D.ln(36, 30, 32, 40, "#a85c48") D.ln(22, 30, 26, 42, "#a85c48")
local function cur(x, y, r, R)
  D.seed(x, y, r, r, 0, R or D.INDIGO)
  D.px(x + 2, y + 2, "#14102e") D.px(x + 3, y + 2, "#9a96e0") D.px(x + 2, y + 3, "#14102e")
  D.px(x - 2, y - 2, "#fff4d6")
end
cur(22, 33, 4.6) cur(37, 33, 4.6) cur(27, 45, 4.8)
cur(41, 46, 4, {"#4a1a18","#8a3a20","#b86a30","#98a838","#b8c850","#dcea8c"})
cur(30, 20, 3.8)
D.fin()
