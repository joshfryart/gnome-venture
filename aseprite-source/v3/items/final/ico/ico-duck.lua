local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-duck: plump yellow rubber duck in profile with an orange beak and a little wing.
-- quirk: three soap bubbles float up from it.
local c = D.new("ico-duck")
c:groundShadow(30, 56, 22, 3)
local Y = { "#a8641c", "#d98a1c", "#f2b02a", "#ffd23c", "#ffe670", "#fff4b0" }
D.lit(c:poly{ { 8, 36 }, { 2, 26 }, { 14, 32 } }, Y, 2)
D.lit(D.ell(30, 44, 21, 12, 0), Y, 8)
D.lit(D.disc(42, 24, 11), Y, 5)
D.lit(D.ell(52, 28, 5, 3), D.ORG, 2)
D.fill(c:rect(48, 29, 56, 29), D.ORG[1])
D.px(44, 21, D.INK) D.px(45, 21, D.INK) D.px(44, 22, D.INK) D.px(44, 21, D.CR)
D.px(47, 25, "#ff9a78") D.px(48, 25, "#ff9a78")
D.lit(D.ell(24, 44, 8, 5, 0.3), Y, 3)
D.fill(c:line({ { 18, 46 }, { 24, 49 }, { 30, 47 } }, 1), Y[2])
for _, b in ipairs{ { 14, 12, 4 }, { 24, 6, 3 }, { 56, 12, 3 } } do
  D.fill(D.ring(b[1], b[2], b[3], b[3] - 1), D.P.sky.shade) D.px(b[1] - 1, b[2] - 1, D.CR)
end
D.fin()
