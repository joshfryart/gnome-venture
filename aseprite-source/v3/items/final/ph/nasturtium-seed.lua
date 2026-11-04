-- nasturtium-seed: three wrinkled three-ridged tan seeds on a scrap; sprout with one round shield (peltate) leaf with radiating veins and a notch. quirk: an orange bud peeks over the leaf edge.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("nasturtium-seed")
D.scrap(c, { ramp = "moss", x0 = 6, y0 = 53, x1 = 58, y1 = 55, w = 6.2 })
local LF = D.R("#d4f090", "#78c050", "#3a8a4c", "#245046")
D.stem(c, { {32,48}, {30,40}, {32,30} }, 1, "#6aa844", "#b0e070")
local lf = c:ellipse(33, 22, 13, 11):cut(c:poly{ {33,10}, {36,15}, {30,15} }):cut(c:rect(28,9,38,12))
B.lit(c, lf, LF, 8)
for k = 0, 8 do local a = pi * .9 + k * (pi * 1.2 / 8) + .1 B.ln(c, 33, 22, 33 + cos(a) * 13, 22 + sin(a) * 11, k % 2 == 0 and LF.hi or LF.shade, lf) end
c:fillMask(c:ellipse(33, 22, 1.2, 1.2), LF.deep)
c:px(27, 16, "#fff4d6")
-- orange bud
B.lit(c, B.ell(47, 14, 2.6, 3.4, 0.6), D.R("#ffe38a", "#ff8a3c", "#d0502e", "#7a2c2e"), 1.8)
D.stem(c, { {45,17}, {42,24} }, 1, "#6aa844", "#b0e070")
local SD = D.R("#f0e0b8", "#bca474", "#8a7050", "#51402e")
for _, s in ipairs{ {16,50}, {30,53}, {47,51} } do
  c:fillMask(B.ell(s[1] + 1, s[2] + 1.2, 4.4, 4, 0), "#1f553f")
  local m = c:ellipse(s[1], s[2], 4, 3.5)
  B.lit(c, m, SD, 3.4)
  for k = 0, 2 do local a = -pi / 2 + k * 2.094 B.ln(c, s[1], s[2], s[1] + cos(a) * 4, s[2] + sin(a) * 3.5, SD.deep, m) end
  c:px(s[1] - 2, s[2] - 2, "#fff4d6")
end
D.fin()
