-- yuzu (lean D3o_16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name="yuzu" }
local YEL  = { "#8a5a14", "#b98320", "#e0a92c", "#f2c84a", "#fadf7a", "#fff2b0" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local STEM = { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }
c:groundShadow(31, 55, 13, 2)
-- lumpy fruit: oval + a few bumps
local f = c:ellipse(31, 37, 15, 14)
f:add(c:ellipse(21, 42, 5, 5)):add(c:ellipse(40, 44, 5, 4)):add(c:ellipse(25, 28, 5, 4)):add(c:ellipse(38, 28, 5, 4))
local n = X.pillow(f, 11)
local v = X.light(n, { amb=0.1, wrap=0.25 })
local bias = {}
-- pitted rind dimples
f:each(function(x, y) local h = X.hash(x, y, 7)
  if h > 0.9 then bias[K(x, y)] = -1 elseif h < 0.04 and v[K(x,y)] > 0.55 then bias[K(x, y)] = 1 end end)
G.toneN(c, f, n, YEL, { bias=bias, amb=0.1, wrap=0.25 })
-- bumpy contour pits (oil glands)
for _, p in ipairs{ {26,34},{33,40},{38,36},{29,46},{22,38},{35,48},{40,41} } do c:put(p[1], p[2], YEL[2]) end
-- bumps' dividing crease
c:line({{22,38},{24,34}}, 1) c:put(23,36,YEL[2])
-- spec
c:fillMask(c:rect(24, 30, 26, 31), YEL[6]) c:put(23,32,YEL[5]) c:put(27,29,"#fffbe8")
-- calyx + short stem
c:fillMask(c:rect(30, 21, 33, 23), STEM[1]) c:fillMask(c:rect(29, 22, 34, 22), STEM[2])
local sm, sn = G.tube({ {31,23}, {31,18}, {32,14}, {33,12} }, function(t) return 1.6 - 0.5*t end)
G.toneN(c, sm, sn, STEM, { amb=0.2, wrap=0.3 })
-- leaf, slightly folded, with midrib (quirk: leaf has a notch bite)
local lm, ln, T, S = G.blade(33, 13, 44, 6, 52, 12, function(t) return 4.2 * math.sin(math.pi * t) ^ 0.7 end, {})
G.toneN(c, lm, ln, LEAF, { amb=0.12, wrap=0.3 })
lm:each(function(x, y) local k = K(x, y)
  if math.abs(S[k]) < 0.18 and T[k] > 0.1 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[2]) end end)
G.save(c, "yuzu")
