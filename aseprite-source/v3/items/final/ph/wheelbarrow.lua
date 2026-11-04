-- wheelbarrow (lean D3o_11)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }
local NAME = "wheelbarrow"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, ramp, R, amb, bias) local n = X.pillow(m, R or 4); G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local PAINT= { "#16423a", "#1f6048", "#2d8458", "#46a468", "#72c484", "#a8e0a8" }
local WOOD = { "#3a2218", "#5a3a26", "#84583a", "#aa7c50", "#cca070", "#e8c8a0" }
local TIRE = { "#1c1620", "#2e2634", "#463e50", "#645c70", "#8a82a0" }
local SOIL = { "#2c1a14", "#4a2e20", "#6e4630", "#926248", "#b88462" }
c:groundShadow(34, 57, 26, 2)
-- rear leg and handles (behind the tub)
local leg = G.tube({ {48, 36}, {49, 45}, {50, 52}, {51, 56} }, function(t) return 1.6 end)
tone(leg, WOOD, 1.5, 0.1)
c:fillMask(c:rect(48, 56, 53, 56), WOOD[1])
-- soil heap with a sprout and a stone
local heap = c:ellipse(30, 23, 14, 5)
heap:add(c:poly{ {17, 25}, {22, 20}, {30, 17}, {38, 20}, {44, 25} })
tone(heap, SOIL, 6, 0.1)
for x = 20, 40, 3 do c:px(x, 21 + (x % 2), SOIL[5]) end
local stone = c:ellipse(37, 20, 2.5, 2)
tone(stone, { "#4a4a5a", "#6a6a7c", "#8e8ea0", "#b0b0c0", "#d0d0da", "#eeeef4" }, 2, 0.15)
G.line(c, { {25, 20}, {25, 15}, {24, 12} }, "#5b8d5a")
local s1 = c:ellipse(22, 11, 2.5, 1.2) local s2 = c:ellipse(27, 12, 2.5, 1.2)
tone(s1, { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }, 1.5, 0.15)
tone(s2, { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }, 1.5, 0.15)
-- tub: deep trapezoid, painted steel
local tub = c:poly{ {13, 25}, {46, 25}, {49, 29}, {42, 42}, {21, 42}, {15, 31} }
local tn = X.pillow(tub, 8)
local bias = {}
for x = 14, 48 do for y = 26, 41 do if tub:has(x, y) and y > 41 - 0 then end end end
G.tone(c, tub, X.light(tn, { amb = 0.1, wrap = 0.25 }), PAINT, CUTS, bias)
-- rolled rim
c:fillMask(c:rect(12, 24, 47, 26), PAINT[5])
for x = 12, 47 do c:px(x, 24, PAINT[6]) c:px(x, 26, PAINT[2]) end
-- ribs and rivets
for x = 20, 40, 7 do for y = 29, 39 do c:px(x, y, PAINT[2]) c:px(x + 1, y, PAINT[4]) end end
for x = 17, 45, 7 do c:px(x, 27, PAINT[6]) end
-- scratch of rust on the lower corner (wear)
for _, p in ipairs{ {41,40},{40,41},{42,39},{39,40} } do c:px(p[1], p[2], "#b0623a") end
-- handles: two long poles out the back, with grips
local hd = G.tube({ {42, 33}, {49, 33}, {54, 34}, {58, 33} }, function(t) return 1.6 end)
tone(hd, WOOD, 1.5, 0.1)
c:fillMask(c:rect(52, 32, 58, 35), WOOD[3])
for x = 52, 58, 2 do c:px(x, 33, WOOD[5]) c:px(x, 35, WOOD[1]) end
-- front frame stay
local st = G.tube({ {22, 41}, {20, 46}, {17, 49}, {16, 50} }, function(t) return 1.3 end)
tone(st, WOOD, 1.2, 0.1)
-- wheel: fat tire, hub and spokes
local wheel = c:ellipse(15, 49, 8, 8)
local tn2 = X.pillow(wheel, 6)
G.tone(c, wheel, X.light(tn2, { amb = 0.1, wrap = 0.2 }), TIRE, { 0.25, 0.5, 0.75, 0.9 })
local rimm = c:ellipse(15, 49, 5, 5)
c:fillMask(rimm, "#c8b078")
c:fillMask(c:ellipse(15, 49, 4, 4), "#8a7448")
for _, d in ipairs{ {0,-3},{0,3},{-3,0},{3,0},{-2,-2},{2,2},{-2,2},{2,-2} } do c:px(15 + d[1], 49 + d[2], "#e8d8a0") end
c:fillMask(c:ellipse(15, 49, 1.2, 1.2), "#fff2b8")
c:px(10, 45, TIRE[5]) c:px(11, 44, TIRE[5])
G.fin(c, NAME)
