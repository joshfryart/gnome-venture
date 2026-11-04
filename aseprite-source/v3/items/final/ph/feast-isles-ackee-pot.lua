-- feast-isles-ackee-pot (lean W2_2)
-- Round iron pot heaped with buttery ackee, wooden spoon standing in it, two ear handles, stubby legs.
-- quirk: a split red ackee pod with two black seeds sits beside the pot.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "feast-isles-ackee-pot"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, max, min = math.floor, math.max, math.min
local IRON = { "#1b1a2e", "#2f2d4a", "#47456a", "#64628c", "#8584ad", "#b3b2d0" }
local ACK = { "#a8741a", "#cf9a24", "#eab93a", "#f7d559", "#fde88c", "#fff6c4" }
local WOOD = { "#4a2a1c", "#6e4226", "#946036", "#b8804a", "#d6a468", "#ecc690" }
local RED = { "#4a1218", "#7a1c24", "#a82e2a", "#d44a30", "#ee7040", "#ffa066" }

c:groundShadow(35, 54, 22, 3)
-- legs
for _, lx in ipairs{ 27, 43 } do
  local lm = c:rect(lx, 48, lx + 3, 52)
  G.toneN(c, lm, X.pillow(lm, 2), IRON, {})
end
-- handles (ear loops)
local hl, hln = G.tube({ { 21, 33 }, { 13, 31 }, { 13, 40 }, { 21, 41 } }, function() return 1.5 end)
G.toneN(c, hl, hln, IRON, {})
local hr, hrn = G.tube({ { 51, 33 }, { 59, 31 }, { 59, 40 }, { 51, 41 } }, function() return 1.5 end)
G.toneN(c, hr, hrn, IRON, {})
-- body
local body, bn = G.oval(36, 38, 17, 13, 0, 1.2)
local bb = {}
body:each(function(x, y) if y < 30 then bb[K(x, y)] = -1 end end)
G.toneN(c, body, bn, IRON, { bias = bb })
body:each(function(x, y)
  if y == 33 then c:px(x, y, IRON[(x < 38) and 4 or 2]) end
  if y == 34 then c:px(x, y, IRON[2]) end
end)
local sx, sy = G.specAt(body, bn, 30)
c:px(25, 36, IRON[6]) c:px(25, 37, IRON[5]) c:px(26, 35, IRON[5]) c:px(26, 40, IRON[4])
-- rim and opening
local rim, rn = G.oval(36, 28, 17.5, 5.5, 0, 3)
G.toneN(c, rim, rn, IRON, {})
local op = G.oval(36, 28.5, 15, 4, 0, 3)
op:each(function(x, y) c:px(x, y, (y <= 27) and IRON[1] or IRON[2]) end)
-- ackee heap
local chunks = { { 28, 27, 4.2, 3 }, { 36, 25, 4.8, 3.4 }, { 44, 27, 4.2, 3 }, { 32, 29, 3.8, 2.6 }, { 40, 29.5, 3.8, 2.6 }, { 36, 28.5, 3.2, 2.2 }, { 31, 24, 3.2, 2.4 }, { 41, 24, 3.2, 2.4 } }
local order = { 4, 5, 1, 3, 2, 7, 8, 6 }
for _, i in ipairs(order) do
  local ch = chunks[i]
  local m, n = G.oval(ch[1], ch[2], ch[3], ch[4], (i % 2 == 0) and 0.3 or -0.3, 0.9)
  G.toneN(c, m, n, ACK, {})
  c:px(ch[1] - 1, ch[2] - 1, ACK[6])
end
for _, p in ipairs{ { 33, 29, "#d4402a" }, { 42, 27, "#d4402a" }, { 30, 26, "#6ea446" }, { 38, 23, "#6ea446" }, { 45, 28, "#e8e0c0" }, { 36, 30, "#e8e0c0" } } do
  c:px(p[1], p[2], p[3])
end
-- wooden spoon
local sm, sn = G.tube({ { 37, 24 }, { 43, 17 }, { 49, 11 }, { 54, 6 } }, function(t) return 1.7 - 0.2 * t end)
G.toneN(c, sm, sn, WOOD, {})
sm:each(function(x, y) if (x * 2 + y) % 5 == 0 then c:px(x, y, WOOD[2]) end end)
c:px(53, 6, WOOD[6])
-- ackee pod (quirk)
local pod, pn = G.oval(13, 49, 8, 4.2, -0.35, 1.3)
G.toneN(c, pod, pn, RED, {})
local sl = G.oval(13, 48.5, 5.6, 1.9, -0.35, 1)
G.toneN(c, sl, select(2, G.oval(13, 48.5, 5.6, 1.9, -0.35, 1)), ACK, {})
c:fillMask(c:rect(11, 47, 12, 48), "#14101c") c:fillMask(c:rect(15, 46, 16, 47), "#14101c")
c:px(11, 47, "#6a6a88") c:px(15, 46, "#6a6a88")
c:px(9, 47, RED[6]) c:px(10, 46, RED[6])
G.save(c, NAME)
