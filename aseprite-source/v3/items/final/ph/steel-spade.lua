-- steel-spade (lean D2o_12)
-- D-grip wooden handle on a tall shaft, riveted socket, rolled-ridge steel blade with a worm and soil clods.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local sin, cos, pi, abs, floor, max, min, sqrt, atan2 = math.sin, math.cos, math.pi, math.abs, math.floor, math.max, math.min, math.sqrt, math.atan
local function solid(c, m, ramp, R, amb) local n = X.pillow(m, R) local idx = G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp) return n, idx end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "steel-spade" }
local WOOD = { "#3a2218", "#5a3624", "#7d4d30", "#a2693c", "#c58a52", "#e3b072" }
local STEEL = { "#2c3a4f", "#4a5f78", "#6f88a2", "#98b0c6", "#c4d6e4", "#f0f7fc" }
c:groundShadow(32, 58, 12, 2)
local handle = c:rect(25, 6, 34, 9):add(c:rect(25, 6, 27, 17)):add(c:rect(25, 15, 34, 17)):add(c:rect(31, 6, 34, 34))
solid(c, handle, WOOD, 2.8)
for y = 19, 32, 1 do if X.hash(32, y, 9) > 0.55 then c:px(32, y, WOOD[2]) end if X.hash(33, y, 4) > 0.8 then c:px(33, y, WOOD[5]) end end
c:px(26, 7, WOOD[6]) c:px(27, 6, WOOD[6]) c:px(28, 6, WOOD[6])
local sock = c:poly{ {29, 31}, {36, 31}, {37, 39}, {28, 39} }
solid(c, sock, STEEL, 4)
c:px(32, 34, STEEL[6]) c:px(33, 34, STEEL[1]) c:px(32, 36, STEEL[5])
local blade = c:poly{ {22, 38}, {43, 38}, {44, 43}, {41, 51}, {37, 56}, {33, 58}, {32, 58}, {28, 56}, {24, 51}, {21, 43} }
solid(c, blade, STEEL, 7, 0.14)
for y = 40, 56 do local x0 = 32 for x = x0, x0 + 1 do if blade:has(x, y) then c:px(x, y, y > 52 and STEEL[3] or STEEL[5]) end end end
G.line(c, { {24, 41}, {26, 47}, {28, 52} }, STEEL[6])
G.line(c, { {23, 42}, {25, 48} }, STEEL[5])
for x = 22, 43 do if blade:has(x, 38) then c:px(x, 38, STEEL[5]) c:px(x, 39, x < 33 and STEEL[3] or STEEL[2]) end end
for x = 23, 42 do if blade:has(x, 40) then c:px(x, 40, STEEL[1]) end end
-- quirk: worm on the shoulder + soil clods at the tip
for _, p in ipairs{ {35, 41, 0}, {36, 40, 0}, {37, 41, 0}, {38, 40, 0}, {39, 41, 0} } do c:px(p[1], p[2], "#e88a9a") end
c:px(39, 40, "#2b1c26") c:px(35, 42, "#b05a6a")
for _, p in ipairs{ {34, 55}, {35, 54}, {36, 55}, {31, 56}, {30, 55}, {37, 53} } do c:px(p[1], p[2], "#6b4230") end
c:px(35, 55, "#8d5d3e") c:px(31, 55, "#8d5d3e")
G.fin(c, "steel-spade")
