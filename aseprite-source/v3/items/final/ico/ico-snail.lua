-- ico-snail first draft. orange spiral shell on a tan body with eyestalks. quirk: a tiny daisy grows on top of the shell
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-snail")
local floor = math.floor
-- slime trail
D.R(c, 6, 55, 50, 56, "#78c8e8")
-- body
D.lit(c, D.ell(30, 50, 24, 6), D.TAN, 3)
D.lit(c, D.ell(12, 42, 6, 9), D.TAN, 3)
c:px(54, 50, "#2b1c26")
-- stalks
D.stalk(c, 9, 36, 7, 22, "#b58650") D.stalk(c, 15, 36, 16, 24, "#b58650")
-- shell
local sh = c:ellipse(37, 33, 15, 15)
D.lit(c, sh, D.ORG, 7)
D.spiral(c, 37, 33, 13, 2.4, "#a8441c", sh, 1.2)
D.spiral(c, 37, 33, 12, 2.4, "#ffaa50", sh, 1.2 + 0.0)
D.lit(c, c:ellipse(37, 33, 3, 3), D.ORG, 1.5)
-- smile
D.pts(c, { {9, 44}, {10, 45}, {11, 45} }, "#6f4033")
-- daisy
for _, p in ipairs{ {37, 14}, {37, 20}, {34, 17}, {40, 17} } do D.lit(c, c:ellipse(p[1], p[2], 2, 2), D.CRM, 1) end
D.R(c, 36, 16, 38, 18, "#ffd45a")
D.fin()
