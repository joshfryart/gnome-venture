-- nav-passport (lean W2_10)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local function slab(c, m, R, ramp, amb, bias) local n = X.pillow(m, R) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) return n end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "nav-passport" }
local BL = { "#14284a", "#1f3d72", "#2f5a9a", "#4a7ac0", "#7aa4dc", "#b0ccf0" }
local PA = { "#8a7a8c", "#b8aa9e", "#d8ccb6", "#eee4cc", "#faf4e2", "#fffdf4" }
local GD = { "#6a3e1c", "#a06a24", "#d49a30", "#f0c850", "#fce48a", "#fff6c4" }
local RD = { "#5a1428", "#8e2238", "#c43a4a", "#e8646a" }
-- page block peeking right and below the cover
local pages = c:rect(21, 12, 47, 54)
slab(c, pages, 3, PA, 0.2)
for y = 16, 52, 3 do c:px(46, y, PA[2]) c:px(45, y + 1, PA[3]) end
-- ribbon bookmark (quirk) hangs from the bottom
c:fillMask(c:rect(38, 54, 40, 57), RD[3]) c:fillMask(c:rect(38, 54, 38, 56), RD[4]) c:fillMask(c:rect(40, 55, 40, 58), RD[2])
c:px(38, 58, RD[3]) c:px(40, 59, RD[2]) c:px(39, 58, RD[1])
-- cover
local cover = c:rrect(17, 8, 43, 53, 2)
local cn = slab(c, cover, 4, BL, 0.1)
-- spine strip
c:fillMask(c:rect(18, 9, 21, 52), BL[1]) c:fillMask(c:rect(21, 9, 21, 52), BL[2]) c:fillMask(c:rect(18, 9, 18, 52), BL[3])
-- cloth weave
cover:each(function(x, y) if x > 22 and x < 42 and y > 10 and y < 52 and (x + y) % 4 == 0 then c:px(x, y, BL[2]) end end)
-- gold border
for x = 24, 40 do c:px(x, 11, GD[3]) c:px(x, 50, GD[2]) end
for y = 11, 50 do c:px(24, y, GD[3]) c:px(40, y, GD[2]) end
-- globe emblem
local gl = c:ellipse(32, 25, 8, 8)
G.tone(c, gl, X.light(X.pillow(gl, 8), { amb = 0.1, wrap = 0.25 }), GD, CUTS)
for x = 26, 38 do c:px(x, 25, GD[2]) end
G.line(c, { {32, 17}, {30, 21}, {30, 29}, {32, 33} }, GD[2]) G.line(c, { {32, 17}, {34, 21}, {34, 29}, {32, 33} }, GD[2])
c:px(28, 20, GD[6]) c:px(29, 19, GD[6]) c:px(28, 21, GD[5])
-- title bars
c:fillMask(c:rect(26, 37, 38, 38), GD[3]) c:fillMask(c:rect(26, 37, 38, 37), GD[5]) c:fillMask(c:rect(28, 41, 36, 41), GD[2])
-- red stamp ring
G.line(c, { {35, 45}, {37, 45}, {38, 46}, {38, 48}, {37, 49}, {35, 49}, {34, 48}, {34, 46}, {35, 45} }, RD[3])
c:px(36, 47, RD[4])
G.fin(c, "nav-passport")
