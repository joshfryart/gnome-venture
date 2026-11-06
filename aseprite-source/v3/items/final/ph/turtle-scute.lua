-- turtle-scute (lean D3o_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local c = HP.canvas{ w=64, h=64, scale=1, name="turtle-scute" }
local AMB = { "#3a2a1c", "#5c4020", "#85602a", "#b0863a", "#d5b052", "#f0d982" }
local MOSS = { "#1f4a35", "#2f6d3f", "#4f9a48", "#8cc760" }
c:groundShadow(33, 55, 17, 3)
local hex = c:poly{ {32,9},{50,20},{50,42},{32,53},{14,42},{14,20} }
local n = X.pillow(hex, 9)
local v = X.light(n, { amb = 0.08, wrap = 0.2 })
local bias = {}
-- concentric hex growth rings (hex distance) + radial seams
hex:each(function(x, y)
  local dx, dy = (x - 32) / 18, (y - 31) / 21
  local d = max(abs(dy) , abs(dx) * 0.87 + abs(dy) * 0.5, 0) * 21
  local k = K(x, y)
  if d % 4.6 < 0.9 and d > 3 then bias[k] = -1 end
  if d % 4.6 >= 3.8 and d > 3 then bias[k] = 1 end
  local ang = atan(dy, dx)
  if d > 5 and abs(((ang * 3 / pi) % 1) - 0.5) < 0.02 then bias[k] = -2 end
end)
-- scored rim: outer 2px darker
local rim = hex:copy():shrink(2)
hex:each(function(x, y) if not rim:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
G.tone(c, hex, v, AMB, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
-- spec
c:px(22, 19, "#fff4cc") c:px(23, 19, "#fff4cc") c:px(22, 20, "#f0d982")
c:px(25, 17, "#fff4cc")
-- central areole
c:px(32, 31, AMB[1]) c:px(33, 31, AMB[2]) c:px(32, 32, AMB[2])
-- quirk: chipped corner and a moss tuft
local chip = c:poly{ {46,14},{54,20},{50,26} }
c:fillMask(chip:copy():cut(hex):add(HP.mask()), AMB[1])
for _, p in ipairs{ {16,41,3},{17,41,2},{18,41,3},{16,40,2},{17,40,4},{18,40,3},{19,41,2},{17,39,3},{16,42,1},{18,42,2},{19,42,1} } do c:px(p[1], p[2], MOSS[p[3]]) end
G.fin(c, "turtle-scute")
