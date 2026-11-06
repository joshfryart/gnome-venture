-- vanilla-extract (lean D3o_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local c = HP.canvas{ w=64, h=64, scale=1, name="vanilla-extract" }
local GL  = { "#4a3a5a", "#6e5a7a", "#9a84a0", "#c9b8c4", "#ecdfe0", "#fffaf2" }
local LIQ = { "#2e1608", "#4f2610", "#7a3d14", "#a85d1c", "#d08a2c", "#f0b84a" }
local COR = { "#5a3a22", "#80582f", "#a8793f", "#cf9d5c" }
local PAP = { "#a89070", "#cdb88e", "#e9d9b0", "#f8efd2" }
c:groundShadow(32, 57, 14, 3)
local body = c:rrect(20, 28, 44, 56, 7)
local neck = c:rect(27, 17, 37, 30)
local lip  = c:rrect(25, 14, 39, 18, 1)
local bottle = body:copy():add(neck):add(lip)
local n = X.pillow(bottle, 7)
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
G.tone(c, bottle, v, GL, { 0.2, 0.38, 0.54, 0.7, 0.86 })
-- liquid
local liq = bottle:copy():shrink(1)
liq:each(function(x, y) if y < 33 then liq.s[K(x, y)] = nil end end)
local ln = X.pillow(liq, 7)
local lv = X.light(ln, { amb = 0.1, wrap = 0.3 })
local bias = {}
liq:each(function(x, y) if y == 33 then bias[K(x, y)] = 2 end end)
G.tone(c, liq, lv, LIQ, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
for x = 23, 40 do if liq:has(x, 33) then c:px(x, 33, LIQ[6]) end end
-- vanilla pod inside
G.line(c, { {24,36},{30,35},{37,36} }, LIQ[1])
c:px(26, 35, LIQ[3])
-- paper label
local lab = c:rect(23, 40, 41, 51)
local labn = X.pillow(lab, 12)
G.tone(c, lab, X.light(labn, { amb = 0.35, wrap = 0.3 }), PAP, { 0.2, 0.4, 0.6, 0.8 })
G.line(c, { {23,40},{41,40} }, PAP[1])
G.line(c, { {23,51},{41,51} }, PAP[1])
-- orchid on label
for _, p in ipairs{ {0,-2},{2,0},{1,2},{-1,2},{-2,0} } do c:px(32 + p[1], 45 + p[2], "#ffffff") c:px(32+p[1], 45+p[2], PAP[4]) end
c:px(32, 45, "#d6962e") c:px(32, 43, PAP[2]) c:px(34, 45, PAP[2])
G.line(c, { {26,48},{29,48} }, LIQ[3]) G.line(c, { {35,48},{38,48} }, LIQ[3])
-- cork
local cork = c:rrect(28, 6, 36, 14, 2)
G.tone(c, cork, X.light(X.pillow(cork, 4), { amb = 0.1, wrap = 0.3 }), COR, { 0.3, 0.55, 0.8 })
c:px(30, 8, COR[1]) c:px(33, 10, COR[1]) c:px(31, 12, COR[1])
-- glass highlight streak
for y = 31, 39 do c:px(22, y, GL[6]) end
for y = 19, 26 do c:px(28, y, GL[6]) end
c:px(23, 29, GL[6])
-- quirk: a drip of extract running down the neck
c:px(37, 19, LIQ[4]) c:px(37, 20, LIQ[4]) c:px(37, 21, LIQ[5]) c:px(38, 23, LIQ[5]) c:px(38, 24, LIQ[6])
G.fin(c, "vanilla-extract")
