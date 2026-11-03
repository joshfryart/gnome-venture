local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-clap")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-clap: two hands meeting in a clap, thumbs forward, fingers fanned up, little cuffs, gold action rays on top.
-- quirk: the left cuff has a stray loose thread and a gold button.
D.lit(c:poly{ {12, 56}, {7, 48}, {22, 30}, {31, 38}, {28, 56} }, D.BLUE, 2)
D.lit(c:poly{ {51, 56}, {56, 48}, {41, 30}, {32, 38}, {35, 56} }, D.TEAL, 2)
local lh = ell(23, 34, 8, 14, 0.5):add(c:line({ {20, 28}, {18, 18} }, 4)):add(c:line({ {24, 26}, {25, 15} }, 4)):add(c:line({ {28, 29}, {31, 17} }, 4))
local rh = ell(41, 34, 8, 14, -0.5):add(c:line({ {44, 28}, {46, 18} }, 4)):add(c:line({ {40, 26}, {39, 15} }, 4)):add(c:line({ {36, 29}, {33, 17} }, 4))
D.lit(lh, "skinA", 3) D.lit(rh, "skinB", 3)
D.px(21, 22, "#c98462") D.px(25, 22, "#c98462") D.px(41, 22, "#8a5638") D.px(38, 22, "#8a5638")
D.rect(32, 20, 32, 30, "#7a4036")
D.lit(ell(30, 40, 4, 4, 0), "skinA", 3)
D.fill(c:rect(11, 47, 11, 56), D.BLUE[2]); D.rect(14, 51, 15, 52, D.YEL[5])
D.px(7, 56, D.CR) D.px(6, 58, D.CR) D.px(8, 59, D.CR)
for _, r in ipairs{ {{32, 6}, {32, 1}}, {{22, 8}, {18, 3}}, {{42, 8}, {46, 3}}, {{13, 15}, {8, 12}}, {{51, 15}, {56, 12}} } do
  D.lit(c:line({ r[1], r[2] }, 2), D.YEL, 1)
end
D.fin()
