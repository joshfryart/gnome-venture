-- spider-silk (lean W2_20)
-- Wooden drop spindle: slim stick with round whorl disc, a spun cone of pale silk wound around it, loose thread looping down to a tiny dangling spider (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spider-silk" }
local abs, sin = math.abs, math.sin
local WOOD = { "#4a2a22", "#6e4030", "#945a3c", "#bb7f50", "#dca872" }
local SILK = { "#6f7ba8", "#97a4c8", "#c3cde2", "#e6ecf6", "#f8fbff", "#fffaf0" }
local st = { r = { name = "silk" } }
c:groundShadow(30, 57, 8, 2)
-- stick
c:fillMask(c:rect(29, 6, 31, 54), WOOD[3])
c:fillMask(c:rect(29, 6, 29, 54), WOOD[4]) c:fillMask(c:rect(31, 6, 31, 54), WOOD[2])
for _, y in ipairs{ 12, 20, 33, 47 } do c:px(30, y, WOOD[1]) end
c:px(29, 8, WOOD[5]) c:px(29, 9, WOOD[5])
-- hook at top
c:fillMask(c:line({ {30,6},{30,4},{33,4},{33,6} }, 1), WOOD[3])
-- whorl disc
local wh = c:ellipse(30, 46, 8, 2)
G.tone(c, wh, X.light(X.pillow(wh, 3), { amb = 0.15, wrap = 0.3 }), WOOD, { 0.2, 0.4, 0.6, 0.8 }, nil, nil)
-- silk cone: wide at bottom (y43) narrowing to top (y16)
local cone = HP.mask()
for y = 16, 43 do
  local t = (y - 16) / 27
  local h = 1.5 + 9 * (t ^ 0.8)
  for x = math.floor(30 - h + 0.5), math.floor(30 + h - 0.5) do cone:set(x, y) end
end
local n = X.pillow(cone, 6)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local bias = {}
cone:each(function(x, y)
  local w = (x - 30) * 0.9 + (y - 16) * 0.8   -- diagonal winding
  if w % 3 < 1 then bias[K(x, y)] = -1 end
end)
G.tone(c, cone, v, SILK, { 0.17, 0.33, 0.5, 0.66, 0.82 }, bias, st)
-- loose thread from cone bottom, loop, to spider
local th = "#c3cde2"
G.line(c, { {38,42},{42,45},{45,50},{44,54},{41,54},{40,51} }, th)
G.line(c, { {41,54},{41,56} }, "#e6ecf6")
-- spider: body + legs
c:fillMask(c:ellipse(41, 58, 2, 1), "#2f2438")
c:px(40, 57, "#6a5a7a") c:px(41, 59, "#2b1c26")
for _, p in ipairs{ {38,56},{38,58},{38,60},{44,56},{44,58},{44,60} } do c:px(p[1], p[2], "#4a3a5c") end
c:px(40, 59, "#4a3a5c") c:px(42, 59, "#4a3a5c")
G.fin(c, "spider-silk")
