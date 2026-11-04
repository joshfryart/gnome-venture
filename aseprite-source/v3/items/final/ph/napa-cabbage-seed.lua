-- napa-cabbage-seed: tiny round reddish-brown seeds on a scrap, sprout with kidney cotyledons and a wavy obovate leaf with a pale midrib. quirk: one seed has a pinprick of white root poking out.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("napa-cabbage-seed")
D.scrap(c, { ramp = "moss", x0 = 6, y0 = 52, x1 = 58, y1 = 56, w = 6.2 })
local LF = D.R("#f0fab0", "#a8d860", "#5aa050", "#2f6a48")
D.stem(c, { {32,48}, {32,40}, {32,30} }, 2, "#e4eeb0", "#fbffd8")
B.lit(c, B.ell(24, 41, 4.4, 2.6, 0.3), LF, 1.8) B.lit(c, B.ell(40, 41, 4.4, 2.6, -0.3), LF, 1.8)
-- wavy obovate leaf
local lf = B.ell(32, 21, 11, 13, 0):add(c:ellipse(32, 14, 9, 7))
for _, p in ipairs{ {21,22},{43,22},{22,30},{42,30} } do lf:cut(c:ellipse(p[1] - (p[1] < 32 and 4 or -4), p[2] + 1, 1.2, 1.5)) end
B.lit(c, lf, LF, 6)
c:fillMask(c:line({ {32,30}, {32,14} }, 2), "#fbffd8")
for k = 0, 4 do local y = 28 - k * 4 B.ln(c, 31, y, 24 - k * .3, y - 4, "#5aa050", lf) B.ln(c, 33, y, 40 + k * .3, y - 4, "#5aa050", lf) end
c:px(28, 12, "#fffaea") c:px(29, 12, "#fffaea")
local SD = D.R("#e0a070", "#8a3c2c", "#5a2224", "#2e1418")
for _, s in ipairs{ {13,52}, {19,55}, {45,54}, {52,52}, {26,56} } do B.seed(c, s[1], s[2], 2.2, 2.2, 0, SD, "#1f553f") end
c:px(46, 56, "#fff4d6") c:px(47, 57, "#fff4d6")
D.fin()
