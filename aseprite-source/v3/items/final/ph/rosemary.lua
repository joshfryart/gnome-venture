-- rosemary (lean P1b_O8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "rosemary" }
local LEAF = { "#1b3a35", "#2c5a46", "#45795a", "#6a9d6c", "#9cc08a", "#d2e4ae" }
local WOOD = { "#3a2418", "#5a3a26", "#7a5233", "#9a6c42", "#b98c5a", "#dcb482" }
local FL   = { "#3b2f7d", "#5a58b8", "#7f88e0", "#aebcf6", "#e0e8ff", "#f2f6ff" }
local P = { {13,58}, {22,45}, {38,31}, {51,9} }
local function pt(t) return G.bez(P, t) end
local function needle(t, side, len)
  local x, y = pt(t)
  local x2, y2 = pt(min(1, t + 0.01))
  local a = math.atan(y2 - y, x2 - x) + side * 0.95
  local bx, by = x + cos(a) * len, y + sin(a) * len
  local cx, cy = x + cos(a - side * 0.35) * len * 0.55, y + sin(a - side * 0.35) * len * 0.55
  local m, n = G.blade(x, y, cx, cy, bx, by, function(u) return 0.35 + 1.15 * sin(pi * min(1, u * 1.05)) ^ 0.7 end, { fold = 0.5 })
  G.toneN(c, m, n, LEAF, { amb = 0.1, wrap = 0.2, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
  return bx, by
end
local t = 0.22
local i = 0
while t < 0.99 do
  local len = 10.5 - 4.5 * t
  needle(t, 1, len) needle(t + 0.02, -1, len - 0.8)
  t = t + 0.04 i = i + 1
end
-- stem
local sm, sn = G.tube(P, function(u) return 1.9 - 1.0 * u end)
G.toneN(c, sm, sn, WOOD, { amb = 0.08, wrap = 0.25 })
sm:each(function(x, y) if X.hash(x, y, 3) > 0.8 then c:px(x, y, WOOD[2]) end end)
-- flowers at tip cluster
for _, f in ipairs{ {47, 12, 0}, {43, 17, 1}, {52, 17, 2}, {49, 22, 3} } do
  local m, n = G.oval(f[1], f[2], 2.4, 2.0, 0.6 * f[3], 1)
  G.toneN(c, m, n, FL, { amb = 0.1, wrap = 0.3 })
  c:px(f[1] - 1, f[2] - 1, FL[6])
end
-- twine bow (quirk)
local RED = { "#6b1f2a", "#a8323a", "#d8574a", "#f08a68" }
local bx, by = pt(0.12)
bx, by = floor(bx + 0.5), floor(by + 0.5)
for dx = -2, 2 do c:px(bx + dx, by + (dx + 2) // 3 - 1, RED[2]) end
c:fillMask(c:ellipse(bx - 4, by - 2, 2.2, 1.5), RED[3]) c:fillMask(c:ellipse(bx + 4, by - 2, 2.2, 1.5), RED[3])
c:px(bx - 5, by - 3, RED[4]) c:px(bx + 3, by - 3, RED[4]) c:px(bx, by - 1, RED[1]) c:px(bx + 1, by + 1, RED[1])
c:px(bx - 1, by + 2, RED[2]) c:px(bx + 2, by + 3, RED[1])
G.save(c, "rosemary")
