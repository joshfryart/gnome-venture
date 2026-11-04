-- white-pelt (lean D3o_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "white-pelt" }
-- fluffy scalloped fleece rug with head, ears, leg stubs, curl tail; tan hide rim lower-right. quirk: sleepy smile.
local FUR = { "#8f86b0", "#b8b0cc", "#d9d3e2", "#efeaee", "#fbf6ec", "#fffdf6" }
local u = HP.mask()
for y = 8, 58 do for x = 6, 58 do
  local dx, dy = x - 32, (y - 35) / 0.82
  local a = atan2(dy, dx)
  local R = 17.5 + 2.0 * sin(7 * a + 1) + 1.1 * sin(13 * a + 2)
  if sqrt(dx * dx + dy * dy) <= R then u:set(x, y) end
end end
for _, L in ipairs{ {13, 21}, {51, 21}, {13, 47}, {51, 47} } do u:add(c:ellipse(L[1], L[2], 5, 4)) end
local head = c:ellipse(32, 14, 6, 5)
u:add(head) u:add(c:ellipse(25, 10, 2, 3)) u:add(c:ellipse(39, 10, 2, 3))
u:add(c:ellipse(32, 56, 3, 3))
local hide = u:shift(2, 2) hide:cut(u)
c:fillMask(hide, "#b98a5c")
hide:each(function(x, y) if not hide:has(x, y + 1) or not hide:has(x - 1, y) then c:px(x, y, "#8a5a3f") end end)
local n, v = shade(c, u, FUR, 9, { amb = 0.2, wrap = 0.35 })
u:each(function(x, y)
  local h = X.hash(x, y, 5)
  if h > 0.93 and not u:has(x + 1, y + 2) == false then c:px(x, y, FUR[2]) c:px(x + 1, y + 1, FUR[2]) end
  if h < 0.05 and v[K(x, y)] > 0.55 then c:px(x, y, FUR[6]) c:px(x - 1, y - 1, FUR[6]) end
end)
-- tail curl
c:px(32, 56, FUR[4]) c:px(31, 55, FUR[6])
-- face (quirk)
c:px(28, 14, "#6b5a74") c:px(29, 15, "#6b5a74") c:px(30, 14, "#6b5a74")
c:px(34, 14, "#6b5a74") c:px(35, 15, "#6b5a74") c:px(36, 14, "#6b5a74")
c:px(32, 17, "#e59aa5") c:px(31, 19, "#6b5a74") c:px(32, 20, "#6b5a74") c:px(33, 19, "#6b5a74")
c:px(26, 9, "#e8b6c0") c:px(38, 9, "#e8b6c0")
c:px(22, 26, FUR[6]) c:px(23, 26, FUR[6]) c:px(23, 27, FUR[6])
G.fin(c, "white-pelt")
