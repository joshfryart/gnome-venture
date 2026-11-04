-- sprinkler-can (lean W2_21)
-- Tall slim teal enamel can, brass hoop bands, arched top handle, long angled spout with a brass rose; sprout label (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sprinkler-can" }
local sqrt, max, min, floor = math.sqrt, math.max, math.min, math.floor
local TEAL  = { "#26304f", "#2a4d66", "#2f7a85", "#4aa59a", "#86cfa6", "#c9f0c0" }
local BRASS = { "#4a2f2a", "#7a4a2c", "#b0753a", "#d9a24e", "#f2cf7a", "#fff0b8" }
local tok = { r = { name = "can" } }
c:groundShadow(31, 56, 17, 3)
-- handle arch (behind body)
local hm, hn = G.tube({ {23, 28}, {20, 8}, {40, 8}, {37, 28} }, function(t) return 1.8 end)
G.tone(c, hm, X.light(hn, { amb = 0.12, wrap = 0.3 }), BRASS, nil, nil, tok)
-- spout
local sm, sn = G.tube({ {40, 49}, {47, 47}, {48, 34}, {51, 25} }, function(t) return 2.9 - 1.5 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), TEAL, nil, nil, tok)
-- body (cylinder shading)
local body = c:rrect(19, 28, 41, 53, 3)
local n = {}
body:each(function(x, y)
  local nx = max(-0.97, min(0.97, (x - 30.5) / 11.8))
  n[K(x, y)] = { nx, 0, sqrt(1 - nx * nx) }
end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
G.tone(c, body, v, TEAL, nil, nil, tok)
body:each(function(x, y) if x == 23 and y > 34 and y < 48 then c:px(x, y, TEAL[6]) end end)
-- brass hoop bands
for _, b in ipairs{ {29, 31}, {49, 51} } do
  local bm = c:rect(19, b[1], 41, b[2])
  bm:cut(c:rect(0, 0, 0, 0))
  G.tone(c, bm, v, BRASS, nil, nil, tok)
end
c:fillMask(c:rect(20, 32, 40, 32), TEAL[1])
c:fillMask(c:rect(20, 52, 40, 52), TEAL[1])
for _, p in ipairs{ {22, 30}, {38, 30}, {22, 50}, {38, 50} } do c:px(p[1], p[2], BRASS[6]) end
-- open top
local top = c:ellipse(30, 28, 11, 3)
c:fillMask(top, "#141a2c")
local rim = top:copy():cut(top:copy():shrink(1))
G.tone(c, rim, v, BRASS, nil, nil, tok)
c:px(26, 29, TEAL[1]) c:px(34, 29, TEAL[1])
-- label plate with sprout
c:fillMask(c:rect(25, 36, 35, 46), "#e8dcb8")
c:fillMask(c:rect(25, 46, 35, 46), "#b8a47c")
c:fillMask(c:rect(35, 36, 35, 46), "#c8b88e")
for x = 25, 35 do c:px(x, 36, "#fff5d8") end
c:px(30, 44, "#6a4a2c") c:px(30, 43, "#4b9650") c:px(30, 42, "#4b9650")
c:px(29, 41, "#70b45a") c:px(28, 40, "#70b45a") c:px(31, 41, "#32764b") c:px(32, 40, "#32764b")
-- rose
local rose = G.rell(52, 22, 0.85, 0.5, 5.2, 2.6)
G.tone(c, rose, X.light(X.pillow(rose, 3), { amb = 0.12, wrap = 0.3 }), BRASS, nil, nil, tok)
for _, p in ipairs{ {49, 22}, {51, 21}, {53, 23}, {55, 22}, {52, 24} } do c:px(p[1], p[2], BRASS[1]) end
c:px(50, 20, BRASS[6])
-- spout joint collar
c:fillMask(c:rect(47, 24, 52, 25), BRASS[3])
-- droplets
for _, p in ipairs{ {56, 28}, {58, 32}, {55, 36}, {57, 41} } do c:px(p[1], p[2], "#5aa8f0") c:px(p[1], p[2] + 1, "#2f6fc0") end
c:px(56, 27, "#d8f0ff") c:px(58, 31, "#d8f0ff")
G.fin(c, "sprinkler-can")
