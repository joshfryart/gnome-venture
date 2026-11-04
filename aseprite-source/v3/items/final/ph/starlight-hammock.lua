-- starlight-hammock (lean W2_27)
-- Two carved posts, twisted rope hooks and a sagging indigo woven cloth sewn with gold stars. Quirk: a tiny star charm dangles on a thread.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 }) G.tone(c, m, v, ramp, o.cuts, o.bias) return n, v end
local function maskf(x0, y0, x1, y1, f) local m = HP.mask() for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end return m end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "starlight-hammock" }
local WOOD = { "#3a2218", "#5b3a24", "#7f5233", "#a2703f", "#c4935a", "#e0b983" }
local NAVY = { "#171b45", "#24296a", "#33409a", "#4a5fc0", "#6f86dc", "#a2b6f2" }
local ROPE = { "#6b5130", "#98763f", "#c49e5a", "#e6cc8c" }
local GOLD = "#ffd95a"
c:groundShadow(32, 57, 24, 3)
-- posts
for _, px in ipairs{ 8, 51 } do
  local m = maskf(px, 13, px + 5, 56, function(x, y) return true end)
  m:add(maskf(px - 1, 9, px + 6, 14, function(x, y) return ((x - px - 2.5) / 4.5)^2 + ((y - 12) / 3.5)^2 <= 1 end))
  local n = X.pillow(m, 4)
  local v = X.light(n, { amb = 0.1, wrap = 0.2 })
  G.tone(c, m, v, WOOD, { 0.2, 0.38, 0.55, 0.72, 0.87 })
  m:each(function(x, y) if (x - px) % 3 == 1 and X.hash(x, floor(y / 5), 5) > 0.4 and y > 15 then c:px(x, y, WOOD[2]) end end)
  c:px(px + 1, 11, WOOD[6]) c:px(px + 1, 10, WOOD[5])
  c:fillMask(c:rect(px - 1, 54, px + 6, 56), WOOD[1])
end
-- cloth
local function top(x) return 21 + 15 * sin(pi * (x - 14) / 36) end
local cloth = maskf(14, 18, 50, 52, function(x, y)
  local u = (x - 14) / 36
  if u < 0 or u > 1 then return false end
  local t = top(x)
  return y >= t and y <= t + 2 + 11 * sin(pi * u) ^ 0.8
end)
local n = X.pillow(cloth, 6)
local v = X.light(n, { amb = 0.14, wrap = 0.3 })
G.tone(c, cloth, v, NAVY, { 0.18, 0.34, 0.5, 0.68, 0.86 })
cloth:each(function(x, y) if (x + y) % 2 == 0 and X.hash(x, y, 6) > 0.55 then c:px(x, y, v[K(x, y)] > 0.5 and NAVY[4] or NAVY[2]) end end)
cloth:copy():cut(cloth:copy():shrink(1)):each(function(x, y) if y < 30 then c:px(x, y, NAVY[5]) end end)
local function star(x, y) c:px(x, y, GOLD) c:px(x - 1, y, GOLD) c:px(x + 1, y, GOLD) c:px(x, y - 1, GOLD) c:px(x, y + 1, GOLD) c:px(x - 1, y - 1, "#c98f2a") end
star(26, 34) star(37, 37) star(32, 30)
c:px(20, 28, GOLD) c:px(44, 29, GOLD) c:px(31, 42, "#fff1b0") c:px(41, 33, "#fff1b0")
-- ropes from posts to cloth ends
G.line(c, { {13, 18}, {15, 20}, {16, 22}, {17, 24} }, ROPE[3])
G.line(c, { {14, 18}, {16, 20}, {17, 22}, {18, 24} }, ROPE[1])
G.line(c, { {51, 18}, {49, 20}, {48, 22}, {47, 24} }, ROPE[3])
G.line(c, { {50, 18}, {48, 20}, {47, 22}, {46, 24} }, ROPE[1])
c:fillMask(c:rect(12, 16, 15, 18), ROPE[2]) c:fillMask(c:rect(48, 16, 51, 18), ROPE[2])
c:px(13, 17, ROPE[4]) c:px(49, 17, ROPE[4])
c:px(14, 20, ROPE[1]) c:px(49, 21, ROPE[1])
-- charm (quirk)
G.line(c, { {32, 49}, {32, 51} }, ROPE[3])
c:fillMask(c:rect(31, 52, 33, 52), GOLD) c:fillMask(c:rect(30, 53, 34, 53), GOLD) c:fillMask(c:rect(31, 54, 33, 54), GOLD) c:px(30, 55, GOLD) c:px(34, 55, GOLD) c:px(32, 51, ROPE[2])
c:px(32, 53, "#fff1b0")
G.fin(c, "starlight-hammock")
