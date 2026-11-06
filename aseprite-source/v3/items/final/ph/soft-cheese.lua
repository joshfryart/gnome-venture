-- soft-cheese (lean D2o_2)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "soft-cheese" }
local function shade(m, ramp, R, bias, cuts) local n = X.pillow(m, R) return G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, cuts, bias) end
-- wedge of soft cheese: creamy top, pale-gold front, tan rind side with holes; a fat drip oozes off the front (quirk)
local CH   = { "#8a5a28", "#c08a34", "#e6b848", "#f4d468", "#fce896", "#fff6c4" }
local RIND = { "#5a3418", "#7e4c24", "#a46c34", "#c8924c" }
c:groundShadow(32, 56, 22, 2)
local top   = c:poly{ {10, 38}, {38, 24}, {54, 32}, {30, 44} }
local front = c:poly{ {10, 38}, {30, 44}, {30, 54}, {10, 47} }
local side  = c:poly{ {30, 44}, {54, 32}, {54, 41}, {30, 54} }
shade(front, CH, 12, nil, { 0.1, 0.25, 0.45, 0.7, 0.9 })
shade(side, RIND, 12)
shade(top, CH, 14, nil, { 0.1, 0.22, 0.34, 0.5, 0.7 })
-- rind edge on top rim and soft creamy bevel
c:line({ {38, 24}, {54, 32} }, 1):each(function(x, y) c:px(x, y, RIND[4]) end)
c:line({ {30, 44}, {54, 32} }, 1):each(function(x, y) c:px(x, y, RIND[3]) end)
c:line({ {10, 38}, {30, 44} }, 1):each(function(x, y) c:px(x, y, CH[6]) end)
-- holes
local function hole(cx, cy, rx, ry) c:fillMask(c:ellipse(cx, cy, rx, ry), CH[1]) c:px(cx - rx + 1, cy - ry + 1, CH[2]) c:px(cx + rx - 1, cy + ry, CH[5]) end
hole(32, 33, 3, 2) hole(22, 36, 2, 1.5) hole(42, 31, 2, 1.5)
hole(19, 44, 2, 2) hole(25, 49, 2, 1.5)
c:px(44, 38, RIND[1]) c:px(47, 35, RIND[1]) c:px(40, 44, RIND[1])
-- drip
local dr = c:rect(19, 49, 21, 54) dr:add(c:ellipse(20, 55, 2, 2))
shade(dr, CH, 3)
c:px(19, 54, CH[6]) c:px(20, 49, CH[3])
-- glossy spec on top
c:px(20, 33, CH[6]) c:px(21, 32, CH[6]) c:px(34, 28, CH[6])
G.fin(c, "soft-cheese")
