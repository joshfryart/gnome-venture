local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-watermelon: juicy half-moon slice, striped green rind, red flesh, big seeds.
-- quirk: one seed has been spat out and zips off with motion ticks.
local c = D.new("ico-watermelon")
local function semi(rx, ry) local m = c:ellipse(30, 20, rx, ry) m:clip(c:rect(0, 20, 63, 63)) return m end
local rind = semi(27, 31)
D.lit(c, rind, D.GRN, 5)
for i = 0, 7 do local x = 8 + i * 6 c:fillMask(c:poly{ {x, 28}, {x + 1, 28}, {x + 3, 50}, {x + 2, 50} }:clip(rind), D.GRN[2]) end
local wh = semi(23, 27) D.lit(c, wh, D.CRM, 4)
local fl = semi(20, 24) D.lit(c, fl, D.RED, 7, { amb = 0.05 })
c:fillMask(c:rect(8, 20, 52, 21), D.CRM[4])
for _, p in ipairs{ {18, 30}, {30, 28}, {42, 30}, {24, 38}, {36, 38}, {30, 46} } do
  c:fillMask(c:ellipse(p[1], p[2], 1.5, 2.5), INK) c:px(p[1] - 1, p[2] - 1, D.GRY[4]) end
D.lit(c, D.ell(53, 11, 3, 2, -0.5), D.BRN, 1)
c:fillMask(c:rect(44, 9, 48, 9), D.CRM[3]) c:fillMask(c:rect(43, 13, 47, 13), D.CRM[3])
D.fin()
