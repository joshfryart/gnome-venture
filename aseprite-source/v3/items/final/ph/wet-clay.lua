-- wet-clay (lean D3o_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }
local NAME = "wet-clay"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, ramp, R, amb, bias) local n = X.pillow(m, R or 4); G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local CLAY = { "#4a2418", "#74382a", "#a0523a", "#c4724a", "#e29862", "#f6c28e" }
local BOARD= { "#3a2a22", "#5a4032", "#7e5c42", "#a07c58", "#c4a074", "#e0c498" }
local WATER= { "#2a5a8a", "#3a7ab0", "#6aa8d0", "#b8e0f0" }
-- potter's board
local bd = c:rrect(7, 44, 57, 54, 2)
tone(bd, BOARD, 3, 0.15)
for x = 10, 54, 7 do c:px(x, 48, BOARD[2]) c:px(x + 1, 48, BOARD[2]) c:px(x + 3, 51, BOARD[2]) end
-- lump
local lump = c:poly{ {18,43}, {16,36}, {19,28}, {25,21}, {33,17}, {41,20}, {46,27}, {48,35}, {46,43}, {38,45}, {26,45} }
lump:add(c:ellipse(32, 36, 14, 9))
local ln = X.pillow(lump, 9)
local bias = {}
c:groundShadow(34, 47, 18, 2)
G.tone(c, lump, X.light(ln, { amb = 0.08, wrap = 0.22 }), CLAY, CUTS, bias)
-- thumb dent: dark crescent + lit lower lip, finger ridges inside
c:fillMask(c:ellipse(30, 31, 5, 4), CLAY[2])
c:fillMask(c:ellipse(31, 32, 4, 3), CLAY[3])
for _, p in ipairs{ {28,30},{29,29},{31,29},{27,32},{29,32},{32,31},{30,34},{33,33} } do c:px(p[1], p[2], CLAY[2]) end
for _, p in ipairs{ {26,34},{27,35},{28,36},{29,36},{30,37},{33,36},{34,35} } do c:px(p[1], p[2], CLAY[5]) end
-- wet gloss: broad streaks
for _, p in ipairs{ {24,26},{25,25},{26,24},{27,23},{28,22} } do c:px(p[1], p[2], CLAY[6]) end
c:px(23, 28, CLAY[6]) c:px(23, 29, CLAY[5]) c:px(40, 27, CLAY[6]) c:px(41, 28, CLAY[5]) c:px(36, 21, CLAY[6]) c:px(37, 21, CLAY[6])
-- coil being rolled, lying in front-right
local cm = G.tube({ {42, 44}, {47, 40}, {52, 44}, {55, 40} }, function(t) return 2.0 end)
tone(cm, CLAY, 2, 0.1)
c:px(47, 38, CLAY[6]) c:px(46, 39, CLAY[5])
-- quirk: a drip hanging from the lump and a blue puddle on the board
c:fillMask(c:rect(21, 44, 21, 46), CLAY[3]) c:px(21, 47, CLAY[4])
c:fillMask(c:ellipse(15, 50, 5, 1.5), WATER[2]) c:fillMask(c:ellipse(14, 49, 3, 0.6), WATER[3]) c:px(12, 49, WATER[4])
G.fin(c, NAME)
