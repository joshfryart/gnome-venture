-- marzipan (lean W2_9)
-- A pale-gold marzipan loaf drawn in 3/4 view (top face + front face), crimped along the top edge, a pink sugar rose
-- with two green leaves on top and a whole almond pressed in the front. Quirk: a thumbprint dent on the end face.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "marzipan" }
local MZ = { "#9c7c4c", "#c4a066", "#dcbb7c", "#ecd290", "#f6e4aa", "#fff4cc" }
local ROSE = { "#7a1f3e", "#a8305a", "#d0507a", "#ee7a9a", "#f9a8bc", "#ffd8e0" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local ALM = { "#4a2c18", "#744522", "#a06a38", "#c8924e", "#e6b878", "#f6dca8" }
c:groundShadow(32, 54, 21, 3)
local front = c:rrect(10, 33, 44, 51, 2)
local top = c:poly{ {10,33}, {18,23}, {52,23}, {44,33} }
local side = c:poly{ {44,33}, {52,23}, {52,41}, {44,51} }
local function paint(m, R, amb, ramp)
  G.tone(c, m, X.light(X.pillow(m, R), { amb = amb, wrap = 0.3 }), ramp, { 0.2, 0.36, 0.52, 0.7, 0.88 })
end
paint(top, 9, 0.35, MZ) paint(front, 9, 0.2, MZ) paint(side, 8, 0.0, MZ)
side:each(function(x, y) if X.hash(x, y, 2) > 0.5 then c:px(x, y, MZ[1]) end end)
-- granular texture
front:each(function(x, y) local h = X.hash(x, y, 9) if h > 0.93 then c:px(x, y, MZ[5]) elseif h < 0.05 then c:px(x, y, MZ[2]) end end)
top:each(function(x, y) if X.hash(x, y, 7) > 0.92 then c:px(x, y, MZ[6]) end end)
-- crimp along top front edge
for x = 11, 43 do if x % 3 ~= 2 then c:px(x, 33, MZ[6]) c:px(x, 34, MZ[2]) else c:px(x, 34, MZ[1]) end end
for i = 0, 8 do c:px(44 + i, 33 - i + 0, MZ[1]) end
-- rose on top
local rc = c:ellipse(30, 26, 6, 4)
paint(rc, 4, 0.1, ROSE)
for _, p in ipairs{ {28,25},{29,25},{30,24},{31,25},{32,26},{31,27},{29,27},{28,26},{30,26} } do c:px(p[1], p[2], ROSE[p[1] % 2 == 0 and 2 or 4]) end
c:px(30, 26, ROSE[1]) c:px(29, 24, ROSE[6]) c:px(28, 24, ROSE[6])
c:fillMask(c:ellipse(38, 27, 3, 1.5), LEAF[3]) c:px(37, 27, LEAF[5]) c:px(40, 27, LEAF[2])
c:fillMask(c:ellipse(22, 27, 3, 1.5), LEAF[3]) c:px(21, 27, LEAF[5]) c:px(24, 27, LEAF[2])
-- almond on front
local al = c:ellipse(22, 42, 6, 4)
al:cut(c:rect(0,0,0,0))
paint(al, 4, 0.1, ALM)
for x = 18, 26 do c:px(x, 42 + (x % 2), ALM[2]) end
c:px(20, 40, ALM[6]) c:px(21, 40, ALM[6])
-- thumbprint on side
for _, p in ipairs{ {47,38},{48,37},{49,38},{48,39},{47,40} } do c:px(p[1], p[2], MZ[1]) end
c:px(48, 38, MZ[3])
G.fin(c, "marzipan")
