-- mung-bean-seed: five small olive-green oval beans with pale seams on a scrap; sprout with a pair of pointed ovate leaves. quirk: a bean is split open, showing a yellow inside.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mung-bean-seed")
D.scrap(c, { ramp = "moss", y0 = 54, y1 = 56, x0 = 7, x1 = 57 })
local LF = D.R("#c4e07a", "#7cc35a", "#3f9150", "#24544a")
D.stem(c, { {32,48}, {32,40}, {32,34} }, 2, "#d4e4a0", "#f0f4c8")
D.leafE(c, 23, 31, 8, 4.4, -0.35, LF, 2)
D.leafE(c, 41, 31, 8, 4.4, 0.35, LF, 2)
D.leafE(c, 32, 22, 4, 4.2, -pi / 2 - 0.1, LF, 1)
local BN = D.R("#d4e890", "#8ca84a", "#587a3a", "#2e4a2c")
for _, s in ipairs{ {14,51,0.3}, {23,53,-0.4}, {41,52,0.5}, {50,52,-0.2} } do
  B.seed(c, s[1], s[2], 3.4, 2.4, s[3], BN, "#1f553f")
  local ca, sa = cos(s[3]), sin(s[3])
  B.ln(c, s[1] - ca * 1.4, s[2] - sa * 1.4, s[1] + ca * 1.4, s[2] + sa * 1.4, "#f0e4b0")
end
-- split bean
local sm = B.ell(32, 53, 3.4, 2.4, 0.1)
c:fillMask(B.ell(33, 54, 3.7, 2.7, .1), "#1f553f")
B.lit(c, sm, BN, 2.4)
c:fillMask(c:rect(30, 52, 34, 53), "#ffe38a") c:px(32, 52, "#fff4d6")
D.fin()
