-- willow-fishing-rod (lean D3o_13)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local function blade(ax, ay, cx, cy, bx, by, wf) return (G.tube({ {ax,ay}, {cx,cy}, {cx,cy}, {bx,by} }, wf)) end
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local WOOD = { "#2e1d1f", "#4b2e2a", "#6e4330", "#93603b", "#b98650", "#dcb36f" }
local COPPER = { "#3a2230", "#6a3a35", "#a05a3a", "#d08a48", "#efb964", "#fff0a8" }
local STONE = { "#2f3040", "#4a4a5e", "#6a6a7c", "#8d8d98", "#b2b0b4", "#d8d4d0" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local function sh(c, m, ramp, R, amb) local n = X.pillow(m, R or 3) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "willow-fishing-rod" }
local ROPE = { "#5a4a3a", "#8a7658", "#b8a47a", "#e0d0a0" }
-- willow rod: slim bowed switch from lower-left grip to upper-right tip
local rm, rn = G.tube({ {11,52}, {24,40}, {36,20}, {52,9} }, function(t) return 2.3 - 1.6 * t end)
G.tone(c, rm, X.light(rn, { amb = 0.1, wrap = 0.25 }), WOOD, CUTS)
-- bark nodes
for _, p in ipairs{ {20,44}, {27,35}, {33,26}, {41,17} } do c:px(p[1], p[2], WOOD[2]) c:px(p[1]+1, p[2]-1, WOOD[5]) end
-- cork grip + reel
local grip = c:line({ {9,54}, {16,47} }, 5)
sh(c, grip, { "#5a3a22", "#8a5a34", "#b98650", "#d9a868", "#ecc888", "#f7dca0" }, 2)
for i = 0, 3 do c:px(11 + i * 2, 52 - i * 2, "#5a3a22") end
local reel = c:ellipse(22, 49, 4, 4)
sh(c, reel, COPPER, 3)
c:fillMask(c:ellipse(22, 49, 1, 1), COPPER[1]) c:px(20, 47, COPPER[6])
c:line({ {19,46}, {24,50} }, 1):each(function(x,y) end)
-- guides (little rings) and line
for _, p in ipairs{ {28,35}, {36,25}, {45,14} } do c:px(p[1]+1, p[2]-2, "#cfd6e0") c:px(p[1]+2, p[2]-2, "#7d8aa0") end
G.line(c, { {52,9}, {55,14}, {56,24}, {55,34} }, "#e8e2d8")
-- bobber
local bob = c:ellipse(55, 38, 3, 4)
sh(c, bob, { "#6a1a2a", "#a02a38", "#d94a4a", "#f06a58", "#ff9a80", "#fff0e0" }, 3)
c:fillMask(c:rect(53, 38, 57, 39), "#f4eee6") c:px(53, 37, "#f4eee6")
c:px(54, 36, "#fff6f2")
-- hook
G.line(c, { {55,42}, {55,46}, {53,48}, {52,46} }, "#a8b4c8") c:px(52, 46, "#e8f0ff")
-- QUIRK: willow leaf sprig tied at the tip
local lf = blade(52, 9, 58, 5, 61, 12, function(t) return 2.2 * sin(pi * t) ^ 0.7 end)
sh(c, lf, LEAF, 2)
local lf2 = blade(50, 10, 44, 6, 41, 8, function(t) return 1.6 * sin(pi * t) ^ 0.7 end)
sh(c, lf2, LEAF, 2)
c:px(52, 9, ROPE[2]) c:px(51, 10, ROPE[3])
G.fin(c, "willow-fishing-rod")
