local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-face-sigh: round yellow face, eyes shut, flat mouth, tired.
-- quirk: a little cloud of breath leaves the mouth (the sigh).
local c = D.new("ico-face-sigh")
local f = D.disc(27, 32, 19)
D.lit(f, D.YEL, 17, { amb = 0.05 })
-- closed eyes: downward arcs
for _, ex in ipairs{ 18, 33 } do
  D.poly(c, { {ex,29},{ex+2,32},{ex+5,32},{ex+7,29} }, "#6f4033")
  D.poly(c, { {ex,30},{ex+2,33},{ex+5,33},{ex+7,30} }, "#6f4033")
end
-- brows sag
D.poly(c, { {17,24},{24,23} }, "#8a5a14") D.poly(c, { {32,23},{39,24} }, "#8a5a14")
D.poly(c, { {22,44},{26,43},{30,43},{34,44} }, "#6f4033") D.poly(c, { {22,45},{26,44},{30,44},{34,45} }, "#6f4033")
c:cheek(14, 38) c:cheek(36, 38)
-- puff
local pf = c:ellipse(51, 45, 4, 4):add(c:ellipse(55, 41, 3, 3)):add(c:ellipse(55, 49, 3, 3)):add(c:ellipse(50, 41, 3, 3))
D.lit(pf, D.FOG, 3, { amb = 0.1 })
D.fin()
