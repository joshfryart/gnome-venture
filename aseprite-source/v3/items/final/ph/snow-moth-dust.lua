-- snow-moth-dust (lean D2o_2)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "snow-moth-dust" }
local function shade(m, ramp, R, bias, cuts) local n = X.pillow(m, R) return G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, cuts, bias) end
-- drawstring cloth pouch heaped with glittering frost dust; a moth-shaped patch sewn on the belly (quirk)
local CLOTH = { "#3a4260", "#566290", "#7886b8", "#9fb0d6", "#c4d2ea", "#e0eaf6" }
local DUST  = { "#6a7fb0", "#93a9d4", "#bcd0ec", "#dcebf8", "#f0f8ff", "#f8fdff" }
local CORD  = { "#6a3f2a", "#a06a3a", "#d49a52", "#f0c878" }
c:groundShadow(32, 55, 14, 2)
-- spilled dust on the ground
shade(c:ellipse(46, 53, 7, 2), DUST, 2)
local body = c:ellipse(32, 43, 14, 11)
body:add(c:poly{ {26, 31}, {38, 31}, {41, 40}, {23, 40} })
shade(body, CLOTH, 11)
-- ruffled top flare
local ruf = c:poly{ {22, 24}, {26, 22}, {30, 25}, {34, 22}, {38, 25}, {42, 23}, {38, 32}, {26, 32} }
shade(ruf, CLOTH, 6)
-- cord with bow
c:fillMask(c:rect(25, 33, 39, 34), CORD[2])
c:fillMask(c:rect(25, 33, 39, 33), CORD[3])
c:fillMask(c:rect(26, 34, 38, 34), CORD[1])
shade(c:ellipse(30, 37, 3, 2), CORD, 2) shade(c:ellipse(35, 37, 3, 2), CORD, 2)
c:line({ {32, 35}, {31, 41}, {33, 44} }, 1):each(function(x, y) c:px(x, y, CORD[2]) end)
-- heaped dust
shade(c:ellipse(32, 24, 9, 5), DUST, 5)
for _, p in ipairs{ {28, 22}, {33, 21}, {36, 24}, {30, 25} } do c:px(p[1], p[2], DUST[6]) end
-- moth patch
local wl = c:ellipse(28, 46, 3, 2) wl:add(c:ellipse(36, 46, 3, 2))
c:fillMask(c:rect(32, 44, 32, 49), "#7a5a3a")
wl:each(function(x, y) c:px(x, y, "#d8b878") end)
c:px(27, 45, "#f6e4b0") c:px(35, 45, "#f6e4b0") c:px(29, 47, "#a08040") c:px(37, 47, "#a08040")
c:px(31, 43, "#7a5a3a") c:px(33, 43, "#7a5a3a")
-- floating glints
c:sparkle(14, 20) c:px(46, 14, DUST[6]) c:px(49, 18, DUST[5]) c:px(18, 13, DUST[5])
G.fin(c, "snow-moth-dust")
