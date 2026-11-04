-- morning-glory-seed: three black wedge seeds (orange-segment shape) on a scrap, sprout with butterfly cotyledons and a heart leaf. quirk: a tiny blue trumpet bud curls on a tendril.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("morning-glory-seed")
D.scrap(c, { ramp = "sea", x0 = 6, y0 = 54, x1 = 58, y1 = 54, w = 6.5 })
local LF = D.R("#c4e07a", "#6cb852", "#3a8a4c", "#24544a")
D.stem(c, { {32,48}, {31,38}, {34,28}, {32,20} }, 1, "#5a9a46", "#a0d070")
D.heart(c, 25, 33, 8, 3.14, LF, true)
D.heart(c, 33, 15, 8.5, -1.5, LF, true)
-- cotyledon butterfly low on the stem
B.lit(c, B.ell(38, 42, 4, 2.6, -0.5), LF, 1.6) B.lit(c, B.ell(30, 44, 3.6, 2.4, 0.4), LF, 1.6)
-- tendril + trumpet bud
D.stem(c, { {35,28}, {42,25}, {48,26}, {49,30}, {46,31} }, 1, "#5a9a46", "#a0d070")
local bud = c:poly{ {46,18}, {53,16}, {52,24}, {47,24} }
B.lit(c, bud, D.R("#c9e4ff", "#5a8af0", "#3a4cc0", "#252a80"), 1.6)
c:px(50, 17, "#fff4d6") c:px(49, 22, "#ffe38a")
local BLK = D.R("#8a80b8", "#3a3358", "#241f3a", "#15121f")
for _, s in ipairs{ {16,50,0.4}, {30,52,2.0}, {44,50,-0.6} } do
  local m = c:poly{ {s[1]-4,s[2]-2}, {s[1]+4,s[2]-3}, {s[1]+2,s[2]+3}, {s[1]-3,s[2]+3} }
  c:fillMask(c:poly{ {s[1]-3,s[2]-1}, {s[1]+5,s[2]-2}, {s[1]+3,s[2]+4}, {s[1]-2,s[2]+4} }, "#1f553f")
  B.lit(c, m, BLK, 2.4, { cuts = { .3, .5, .7, .85, .95 } })
  c:px(s[1] - 2, s[2] - 2, "#b8b0e0") c:px(s[1] - 1, s[2] - 2, "#b8b0e0")
  B.ln(c, s[1] - 1, s[2] - 1, s[1] + 1, s[2] + 2, "#15121f", m)
end
D.fin()
