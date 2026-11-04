-- stuffed-peppers-goat (lean W2_31)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stuffed-peppers-goat" }
local PEP = { "#4a0f26", "#7a1530", "#a81f34", "#d03a3a", "#ee6048", "#ff9a72" }
local CHS = { "#8a7f9a", "#b2a9bc", "#d8d0d6", "#f0eae4", "#fbf6ec", "#fffdf6" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local ltok = { r = { name = "leaf" } }
c:groundShadow(32, 55, 22, 3)
-- pepper boat
local shell = c:ellipse(32, 36, 22, 18)
shell:cut(c:rect(0, 0, 63, 31))
shell:add(c:ellipse(32, 31, 22, 4))
local n = X.pillow(shell, 14)
local v = X.light(n, { amb = 0.1, wrap = 0.22 })
local bias = {}
shell:each(function(x, y)
  for _, gx in ipairs{ 20 + floor((y - 31) * -0.25), 44 + floor((y - 31) * 0.25), 32 } do
    if x == gx and y > 36 and y < 52 then bias[K(x, y)] = -1 end
  end
end)
G.tone(c, shell, v, PEP, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
c:px(16, 40, "#fff0e4") c:px(16, 41, "#fff0e4") c:px(17, 39, PEP[6]) c:px(17, 43, PEP[6])
-- stem nub at left end
local sm, sn = G.tube({ {12,35},{9,33},{7,30},{8,27} }, function(t) return 2.4 - 1.0 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }, { 0.3, 0.55, 0.8 })
-- goat cheese stuffing
local ch = c:ellipse(32, 30, 18, 9)
ch:cut(c:rect(0, 34, 63, 63))
local cn = X.pillow(ch, 9)
local cv = X.light(cn, { amb = 0.15, wrap = 0.3 })
local cb = {}
ch:each(function(x, y) if y > 24 and X.hash(x, y, 7) > 0.8 then cb[K(x, y)] = -1 end end)
G.tone(c, ch, cv, CHS, { 0.17, 0.33, 0.5, 0.66, 0.82 }, cb)
-- toasted patches
ch:each(function(x, y)
  local h = X.hash(floor(x / 2), floor(y / 2), 9)
  if y < 29 and cv[K(x, y)] > 0.35 and h > 0.72 and ch:has(x, y - 1) and ch:has(x + 1, y) then
    c:px(x, y, h > 0.88 and "#b97a3c" or "#e0aa62")
  end
end)
-- herb flecks
for _, p in ipairs{ {24,29},{28,26},{33,28},{37,26},{41,30},{30,31},{36,32},{26,32} } do if ch:has(p[1], p[2]) then c:px(p[1], p[2], LEAF[4]) c:px(p[1] + 1, p[2], LEAF[2]) end end
c:px(27, 24, CHS[6]) c:px(28, 24, CHS[6]) c:px(26, 25, "#ffffff" == nil and "" or CHS[5])
-- cheese drip over rim (quirk)
for _, p in ipairs{ {44,33},{44,34},{44,35},{45,35} } do c:px(p[1], p[2], CHS[4]) end
c:px(44, 36, CHS[3])
-- basil sprig
local function lf(pts, w)
  local m, nn = G.tube(pts, function(t) return w * sin(pi * min(1, t * 0.85 + 0.1)) ^ 0.7 + 0.5 end)
  G.tone(c, m, X.light(nn, { amb = 0.15, wrap = 0.3 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, ltok)
end
lf({ {34,26},{36,21},{40,17},{45,17} }, 3.0)
lf({ {34,26},{32,22},{29,18},{25,17} }, 2.6)
lf({ {34,26},{34,22},{34,18},{34,14} }, 2.2)
G.fin(c, "stuffed-peppers-goat")
