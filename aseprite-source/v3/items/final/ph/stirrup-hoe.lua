-- stirrup-hoe (lean W2_28)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stirrup-hoe" }
local WOOD = { "#3d2318", "#5e3a22", "#855331", "#a87040", "#c9914f", "#e8b872" }
local IRON = { "#2f3550", "#4c5878", "#6f7fa0", "#96a8c4", "#bccbdc", "#e6eef4" }
local RED = { "#6b1f33", "#a02f45", "#d14d56" }
local function toned(m, ramp, R, o)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, { 0.2, 0.38, 0.55, 0.7, 0.86 })
end
-- handle
local hm, hn = G.tube({ {12, 55}, {20, 45}, {26, 35}, {32, 26} }, function(t) return 1.5 + 0.5 * t end)
G.tone(c, hm, X.light(hn, { amb = 0.12, wrap = 0.3 }), WOOD, { 0.2, 0.38, 0.55, 0.7, 0.86 })
hm:each(function(x, y)
  if X.hash(x, y, 7) > 0.8 then c:px(x, y, WOOD[2]) end
  if y >= 47 and y <= 50 then c:px(x, y, (y == 47 or y == 50) and RED[1] or ((x + y) % 2 == 0 and RED[3] or RED[2])) end
end)
c:px(11, 56, WOOD[1]) c:px(12, 56, WOOD[1])
-- stirrup head: flat D loop, bevelled
local head = c:rect(28, 10, 52, 26)
head:cut(c:rect(33, 14, 47, 22))
toned(head, IRON, 5)
head:each(function(x, y)
  local l = not head:has(x - 1, y) or not head:has(x, y - 1)
  local d = not head:has(x + 1, y) or not head:has(x, y + 1)
  if l and not d then c:px(x, y, IRON[5]) elseif d and not l then c:px(x, y, IRON[1]) end
end)
for x = 30, 36 do c:px(x, 11, IRON[6]) end
c:px(50, 24, IRON[2]) c:px(49, 25, IRON[2])
-- shadow inside the loop on the lower edge
for x = 33, 47 do c:px(x, 22, IRON[1]) end
-- socket collar + rivet
local col = c:rect(29, 24, 35, 29)
toned(col, IRON, 3)
for x = 29, 35 do c:px(x, 29, IRON[1]) end
c:px(32, 26, IRON[6]) c:px(32, 27, IRON[2])
-- quirk: a tiny weed sprout poking through the loop
for _, p in ipairs{ {40, 21, 2}, {40, 20, 2}, {41, 19, 3}, {39, 19, 3} } do c:px(p[1], p[2], p[3] == 2 and "#47803f" or "#94c45c") end
G.fin(c, "stirrup-hoe")
