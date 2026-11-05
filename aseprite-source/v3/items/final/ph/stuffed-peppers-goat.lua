-- stuffed-peppers-goat (lean P1b_O15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local H = X.hash
local NAME = "stuffed-peppers-goat"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local RED = { "#4b0f2a", "#7d1530", "#b01f33", "#d93a3a", "#f06a4c", "#ff9b6e" }
local CH = { "#8b7490", "#b8a8a8", "#dccfbc", "#f3e8d2", "#fff6e2", "#fffdf2" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local RY = 36
c:groundShadow(32, 56, 24, 3)
-- pepper bowl
local full, fn = G.oval(32, RY, 24, 20, 0, 1)
local bowl = full:copy()
full:each(function(x, y) if y < RY then bowl:cut(c:rect(x, y, x, y)) end end)
G.toneN(c, bowl, fn, RED, { amb = 0.1, wrap = 0.2 })
-- faint rib creases
for _, p in ipairs{ {22,46},{22,47},{23,48},{23,49},{42,46},{42,47},{41,48},{41,49},{32,50},{32,51},{32,52} } do c:put(p[1], p[2], RED[2]) end
-- gloss streak on bowl
for _, p in ipairs{ {16,42},{16,43},{17,44},{17,45},{18,46} } do c:put(p[1], p[2], RED[6]) end
c:put(15, 41, "#fffaf0")
-- rim ellipse and lining
local rimM, rn = G.oval(32, RY, 24, 6.5, 0, 2)
G.toneN(c, rimM, rn, RED, { amb = 0.3, wrap = 0.4 })
local lin = c:ellipse(32, RY, 21, 4.4)
lin:each(function(x, y) c:put(x, y, y > RY and "#e3a23a" or "#b8421f") end)
-- goat cheese dome
local cm, cn = G.oval(32, 35, 20, 15, 0, 1)
local dome = cm:copy()
cm:each(function(x, y) if y > 37 then dome:cut(c:rect(x, y, x, y)) end end)
local ci, cv = G.toneN(c, dome, cn, CH, { amb = 0.1, wrap = 0.3 })
dome:each(function(x, y)
  local k = K(x, y)
  if y < 31 and cv[k] > 0.35 and H(floor(x / 2), floor(y / 2), 5) > 0.62 then c:put(x, y, (H(x, y, 2) > 0.5) and "#e0a64e" or "#c2833a") end
  if H(x, y, 8) > 0.93 then c:put(x, y, LEAF[3]) end
  if H(x, y, 12) > 0.965 then c:put(x, y, "#4a3a44") end
end)
-- cheese drips over the front rim
for _, d in ipairs{ {44, 37, 5}, {22, 38, 3} } do
  for dy = 0, d[3] do c:put(d[1], d[2] + dy, CH[4]) c:put(d[1] + 1, d[2] + dy, CH[3]) c:put(d[1] - 1, d[2] + dy, CH[5]) end
  c:put(d[1] + 1, d[2] + d[3], CH[2]) c:put(d[1], d[2] + d[3] + 1, CH[3])
end
-- glint
c:put(24, 25, CH[6]) c:put(25, 25, CH[6]) c:put(24, 26, CH[6])
-- basil leaf (quirk) + small sprig
local bm, bn = G.oval(38, 21, 7, 3.6, -0.6, 1.2)
G.toneN(c, bm, bn, LEAF, { amb = 0.1, wrap = 0.3 })
for t = -5, 5 do c:put(floor(38 + cos(-0.6) * t + 0.5), floor(21 + sin(-0.6) * t + 0.5), LEAF[6]) end
local bm2, bn2 = G.oval(29, 22, 5, 2.6, 0.5, 1.2)
G.toneN(c, bm2, bn2, LEAF, { amb = 0.1, wrap = 0.3 })
-- pepper stem at upper-left shoulder
local sm, sn = G.tube({ {12, 38}, {9, 34}, {8, 29}, {10, 26} }, function(t) return 2.2 - 0.6 * t end)
G.toneN(c, sm, sn, LEAF, { amb = 0.12, wrap = 0.3 })
G.save(c, NAME)
