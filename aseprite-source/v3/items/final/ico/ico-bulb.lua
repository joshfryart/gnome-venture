local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-bulb")
local CR, INK = D.CR, D.INK
-- ico-bulb: bold glass bulb, warm glow core, zigzag filament, brass-grey screw base with 3 threads.
-- quirk: a tiny moth hovering at the glass, drawn to the light.
local glass = c:ellipse(32, 24, 14, 15):add(c:poly{ {22, 32}, {42, 32}, {38, 44}, {26, 44} })
D.lit(glass, D.YEL, 9, { amb = 0.12 })
D.fill(c:ellipse(32, 25, 8, 9), "#fff0a8")
D.lit(c:ellipse(32, 25, 7, 8), { "#f8cc3e", "#ffe27a", "#fff0a8", "#fff6c0", "#fffbe0", CR }, 6, { amb = 0.3 })
D.poly(c, { {28, 40}, {28, 30}, {30, 26}, {32, 31}, {34, 26}, {36, 30}, {36, 40} }, "#e8872e")
D.px(28, 28, CR) D.px(29, 27, CR)
for i, y in ipairs{ 45, 49, 53 } do
  D.lit(c:rect(26, y, 37, y + 2), D.GRY, 1.5, { amb = 0.15 })
  D.rect(26, y + 2, 37, y + 2, D.GRY[2])
end
D.lit(c:rect(29, 55, 34, 57), D.DBRN, 1.5)
-- moth
D.fill(c:ellipse(51, 14, 3, 2), "#c9b2f0") D.fill(c:rect(51, 13, 52, 16), "#5a459e")
D.px(49, 13, CR) D.px(50, 12, CR) D.px(53, 12, INK)
D.fin()
