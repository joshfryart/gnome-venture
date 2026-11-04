-- tortoise-scute (lean D3o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tortoise-scute" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CU = { 0.2, 0.38, 0.55, 0.72, 0.87 }
local function sh(m, ramp, R, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, CU, bias, tok)
  return n, v
end
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local R = { "#3a3320", "#5e5128", "#85722f", "#aa9440", "#cdb860", "#eadc92" }
local hex = c:poly{ {32,6},{54,19},{54,45},{32,58},{10,45},{10,19} }
hex:cut(c:poly{ {54,40},{48,46},{58,50} })   -- quirk: chipped corner
sh(hex, R, 14)
local rim = hex:copy():cut(hex:copy():shrink(3))
rim:each(function(x, y) if x + y < 64 then c:px(x, y, R[5]) else c:px(x, y, R[2]) end end)
for k = 1, 3 do
  local inner = hex:copy():shrink(2 + k * 4)
  local ring = inner:copy():cut(inner:copy():shrink(1))
  local lr = ring:copy():shift(1, 1):cut(ring):clip(inner)
  lr:each(function(x, y) c:px(x, y, R[5]) end)
  ring:each(function(x, y) c:px(x, y, (x + y < 64) and R[2] or R[1]) end)
end
-- seams from corners
for _, s in ipairs{ {{32,6},{32,13}}, {{54,19},{48,23}}, {{54,45},{48,41}}, {{32,58},{32,51}}, {{10,45},{16,41}}, {{10,19},{16,23}} } do
  G.line(c, s, R[1])
end
local ar = c:poly{ {32,23},{39,27},{39,35},{32,39},{25,35},{25,27} }
sh(ar, R, 5)
c:px(30, 28, R[6]) c:px(31, 28, R[6])
-- moss
local moss = c:ellipse(15, 43, 5, 3):clip(hex)
sh(moss, LEAF, 3)
c:px(13, 41, LEAF[6]) c:px(17, 45, LEAF[1])
c:px(18, 19, "#fff6d8") c:px(19, 19, "#fff6d8") c:px(18, 20, R[6])
G.fin(c, "tortoise-scute")
