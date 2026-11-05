-- feast-isles-ackee-pot (lean P1b_O1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local NAME = "feast-isles-ackee-pot"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local IRON = { "#15122a", "#272a4f", "#3d4a7c", "#5d73a8", "#8ea8d2", "#cfe0f2" }
local ARIL = { "#c27a12", "#e6a41e", "#fbc72e", "#ffdf55", "#fff08a", "#fffbd0" }
local POD = { "#5a0f22", "#8c1a2a", "#c3283a", "#e8483f", "#ff7a58", "#ffb28a" }
local WOOD = { "#4a2a1c", "#74421f", "#a2652e", "#cf9348" }
local SEED = { "#0d0a14", "#1c1626", "#3a3050" }
c:groundShadow(36, 56, 21, 3)
-- spoon first (behind)
local sm, sn = G.tube({ {36, 26}, {41, 18}, {46, 12}, {52, 7} }, function(t) return 1.6 - 0.4 * t end)
G.toneN(c, sm, sn, WOOD, {})
-- pot body
local CX, CY = 36, 41
local body = c:ellipse(CX, CY, 18, 14):cut(c:rect(0, 0, 63, 29))
local feet = c:rect(24, 52, 28, 55):add(c:rect(44, 52, 48, 55))
G.toneN(c, feet, X.pillow(feet, 2), IRON, {})
local lug = HP.mask()
lug:add(c:ellipse(16, 36, 4, 4)):cut(c:ellipse(16, 36, 2, 2)):add(c:ellipse(56, 36, 4, 4)):cut(c:ellipse(56, 36, 2, 2))
G.toneN(c, lug, X.pillow(lug, 2), IRON, {})
local bn = X.pillow(body, 12)
G.toneN(c, body, bn, IRON, { amb = 0.05, wrap = 0.2, cuts = { 0.3, 0.46, 0.62, 0.76, 0.9 } })
-- hammered dents
body:each(function(x, y) if y > 33 and X.hash(x, y, 5) > 0.93 then c:px(x, y, IRON[2]) end end)
c:px(24, 37, IRON[6]) c:px(25, 36, IRON[6]) c:px(24, 38, IRON[5]) c:px(25, 40, IRON[5]) c:px(26, 35, IRON[5])
-- rim
local rimO = c:ellipse(CX, 29, 17, 4.6)
local rimI = c:ellipse(CX, 29, 14, 3.2)
local rim = rimO:copy():cut(rimI)
G.toneN(c, rim, X.pillow(rim, 2), IRON, { amb = 0.2 })
rim:each(function(x, y) if y <= 28 and x < CX then c:px(x, y, IRON[5]) end end)
-- ackee arils heaped in the mouth
local pots = { {28,27,4.4,3.2}, {35,25,4.6,3.4}, {42,27,4.4,3.2}, {32,29,4,2.8}, {39,30,3.8,2.6}, {25,30,3.2,2.2}, {45,30,3.2,2.2} }
for i, p in ipairs(pots) do
  local m = c:ellipse(p[1], p[2], p[3], p[4]):clip(c:ellipse(CX, 28, 15.5, 5.5))
  G.toneN(c, m, X.pillow(m, 3), ARIL, { amb = 0.1 })
  if i <= 5 then local sx = p[1] + (i % 2 == 0 and 1 or -1) * 1
    local s = c:ellipse(sx, p[2], 1.4, 1.1)
    c:fillMask(s, SEED[1]) c:px(sx - 1, p[2] - 1, SEED[3]) end
end
-- steam
c:px(33, 18, "#f6f2ff") c:px(32, 17, "#dcd6f0") c:px(33, 16, "#f6f2ff") c:px(34, 15, "#dcd6f0")
-- red ackee pod, split, in front-left (quirk: a seed rolled out)
local pod = c:ellipse(15, 52, 8, 5):cut(c:rect(0, 0, 63, 47))
local pod2 = c:ellipse(15, 51, 8, 5)
G.toneN(c, pod2, X.pillow(pod2, 4), POD, { amb = 0.12 })
local slit = c:ellipse(15, 50, 5.5, 2.2)
G.toneN(c, slit, X.pillow(slit, 2), ARIL, { amb = 0.2 })
local sd = c:ellipse(14, 50, 1.8, 1.3) c:fillMask(sd, SEED[1]) c:px(13, 49, SEED[3])
c:px(11, 48, POD[6]) c:px(10, 49, POD[6]) c:px(12, 47, POD[5])
local rs = c:ellipse(24, 57, 1.8, 1.3) c:fillMask(rs, SEED[2]) c:px(23, 56, SEED[3])
G.save(c, NAME)
