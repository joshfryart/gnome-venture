-- wasp-stinger (lean D3o_9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="wasp-stinger" }
local AMB = { "#3a1c10", "#6a3410", "#a05c14", "#d28a1c", "#f0b834", "#ffe070" }
local BLK = { "#14101a", "#241c2c", "#3a2e44", "#574a62", "#7a6a82", "#a898ac" }
local VEN = { "#4a6a18", "#7a9e24", "#a8cc3a", "#d4ee6a", "#f2ff9a" }
c:groundShadow(32, 56, 12, 2)
-- needle: long curved crescent tapering to a point
local nm, nn, T, S = G.tube({ {26,26},{26,42},{36,52},{50,55} }, function(t) return 3.4*(1 - t)^0.8 + 0.3 end)
G.tone(c, nm, X.light(nn, {amb=0.1, wrap=0.25}), BLK)
nm:each(function(x, y) local k = K(x, y)
  if S[k] < -0.35 and T[k] > 0.1 and T[k] < 0.85 then c:px(x, y, BLK[6]) end end)
-- barbs: two little backward hooks near the tip
for _, b in ipairs{ {41,52,39,56,42,54}, {46,54,45,58,47,55} } do
  c:poly{ {b[1],b[2]},{b[3],b[4]},{b[5],b[6]} }:each(function(x, y) c:px(x, y, BLK[3]) end)
  c:px(b[3], b[4], BLK[5])
end
-- venom sac: banded plump bulb on top
local sac = G.rell(26, 17, 0.3, 1, 11.5, 9)
local sn = X.pillow(sac, 9)
local bias = {}
sac:each(function(x, y) local k = K(x, y)
  local band = floor((y - 6) / 4.2) % 2
  if band == 1 then bias[k] = -3 end end)
G.tone(c, sac, X.light(sn, {amb=0.08, wrap=0.25}), AMB, nil, nil)
-- black bands drawn over amber
sac:each(function(x, y) local k = K(x, y)
  local band = floor((y - 6) / 4.4) % 2
  if band == 1 then
    local lv = X.light(sn, {amb=0.08, wrap=0.25})[k]
    c:px(x, y, lv > 0.75 and BLK[4] or (lv > 0.5 and BLK[3] or (lv > 0.28 and BLK[2] or BLK[1])))
  end end)
-- sac highlight
c:px(19, 12, AMB[6]) c:px(20, 11, AMB[6]) c:px(19, 13, AMB[5])
-- collar where sac meets needle
c:rect(23, 26, 29, 27):each(function(x, y) c:px(x, y, BLK[2]) end)
-- venom drip at tip (quirk)
c:px(51, 55, VEN[2]) c:px(52, 56, VEN[3]) c:px(52, 57, VEN[2]) c:px(52, 58, VEN[4])
G.fin(c, "wasp-stinger")
