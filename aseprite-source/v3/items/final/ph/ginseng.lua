-- ginseng (lean W2_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ginseng" }
local sin, cos, pi, abs, floor = math.sin, math.cos, math.pi, math.abs, math.floor
local ROOT = { "#7a5a3c", "#a68257", "#cfaa76", "#e8cb98", "#f6e4b8", "#fff4d6" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local BERRY = { "#5a1220", "#8e1c2a", "#c22f35", "#e8523f", "#ff8a62", "#ffd0a8" }
local rtok, ltok = { r = { name = "root" } }, { r = { name = "leaf" } }
local function limb(p, w0, w1)
  local m, n = G.tube(p, function(t) return w0 + (w1 - w0) * t end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), ROOT, { 0.2, 0.38, 0.55, 0.72, 0.88 }, nil, rtok)
  return m
end
-- limbs first, body over them
limb({ {31,44},{28,49},{26,53},{25,59} }, 2.4, 0.6)
limb({ {33,44},{36,48},{39,53},{41,59} }, 2.4, 0.6)
limb({ {30,31},{25,30},{21,33},{17,34} }, 1.9, 0.5)
limb({ {34,31},{39,31},{43,30},{47,33} }, 1.9, 0.5)
local body = limb({ {32,23},{30,31},{34,39},{32,47} }, 5.4, 2.8)
-- growth rings (the ginseng's wrinkles)
for _, y in ipairs{ 26, 29, 34, 37, 41 } do
  body:each(function(x, yy) if yy == y and X.hash(x, yy, 3) > 0.25 then c:px(x, yy, ROOT[1]) end end)
end
-- quirk: red ribbon knotted round the neck
for x = 27, 37 do c:px(x, 24, "#c22f35") c:px(x, 25, x > 33 and "#8e1c2a" or "#e8523f") end
c:px(37, 26, "#c22f35") c:px(38, 27, "#8e1c2a") c:px(26, 26, "#c22f35")
-- stalk
local sm, sn = G.tube({ {32,22},{32,19},{32,16},{32,12} }, function() return 0.8 end)
G.tone(c, sm, X.light(sn, {}), LEAF, nil, nil, ltok)
-- palmate whorl: 5 leaflets
for _, a in ipairs{ -2.7, -2.0, -1.57, -1.1, -0.4 } do
  local ux, uy = cos(a), sin(a)
  local m = G.rell(32 + ux * 6, 14 + uy * 5.5, ux, uy, 6, 2.5)
  local nn = X.pillow(m, 2)
  G.tone(c, m, X.light(nn, { amb = 0.15, wrap = 0.3 }), LEAF, nil, nil, ltok)
  for t = 1, 9 do c:px(floor(32 + ux * t + 0.5), floor(14 + uy * t * 0.9 + 0.5), LEAF[6]) end
end
-- berry cluster
for _, b in ipairs{ {32,6,2.3},{29,8,2},{35,8,2},{32,10,1.9} } do
  local m = c:ellipse(b[1], b[2], b[3], b[3])
  G.tone(c, m, X.light(X.pillow(m, b[3]), { amb = 0.1, wrap = 0.2 }), BERRY, nil, nil, { r = { name = "berry" } })
end
c:px(31, 5, BERRY[6]) c:px(28, 7, BERRY[6]) c:px(34, 7, BERRY[6])
G.fin(c, "ginseng")
