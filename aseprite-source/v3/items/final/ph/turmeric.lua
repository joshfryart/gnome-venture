-- turmeric (lean D3o_7)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "turmeric" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CU = { 0.2, 0.38, 0.55, 0.72, 0.87 }
local function sh(m, ramp, R, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, CU, bias, tok)
  return n, v
end
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local RH = { "#5b3a1c", "#8a5a22", "#b98030", "#d9a244", "#efc462", "#fbe29a" }
local CUT = { "#a04a10", "#cf6a14", "#f08c1c", "#ffb030", "#ffd060", "#ffe8a0" }
-- leaf
local lm, ln, lT = G.tube({ {28,33},{25,22},{29,12},{38,6} }, function(t) return 0.8 + 4.2 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.8 end)
G.tone(c, lm, X.light(ln, { amb = 0.12, wrap = 0.3 }), LEAF, CU)
local mr = G.tube({ {28,33},{25,22},{29,12},{37,7} }, function(t) return 0.4 end)
mr:clip(lm):each(function(x, y) c:px(x, y, LEAF[6]) end)
local function finger(pts, rad, rings)
  local m, nn, T = G.tube(pts, function(t) return rad * (1 - 0.25 * t) end)
  G.tone(c, m, X.light(nn, { amb = 0.1, wrap = 0.3 }), RH, CU)
  m:each(function(x, y)
    local t = T[K(x, y)]
    for _, r in ipairs(rings) do if abs(t - r) < 0.035 then c:px(x, y, RH[2]) end end
  end)
end
finger({ {22,45},{17,50},{15,54},{17,57} }, 3.1, { 0.4, 0.75 })
finger({ {30,47},{33,52},{38,54},{43,53} }, 2.8, { 0.35, 0.7 })
finger({ {36,38},{44,36},{50,38},{53,43} }, 3.4, { 0.3, 0.6 })
-- cut face at the end of the right finger
local face = c:ellipse(52, 44, 3.4, 4.2)
sh(face, CUT, 4)
c:px(51, 42, CUT[6]) c:px(52, 42, CUT[5])
-- mother rhizome
local mother = G.rell(29, 40, 1, -0.2, 12, 8)
local mn, mv = sh(mother, RH, 9)
mother:each(function(x, y)
  if x % 5 == 0 and X.hash(x, y, 3) > 0.35 and mv[K(x, y)] < 0.8 then c:px(x, y, RH[2]) end
  if X.hash(x, y, 8) > 0.93 and mv[K(x, y)] > 0.5 then c:px(x, y, RH[5]) end
end)
c:px(21, 35, RH[6]) c:px(22, 35, RH[6]) c:px(21, 36, RH[5])
-- little shoot nub where the leaf rises
c:px(28, 32, RH[3]) c:px(29, 32, RH[2])
-- powder mound (quirk)
local mound = c:ellipse(50, 56, 6, 3.5):cut(c:rect(0, 0, 63, 53))
sh(mound, CUT, 5)
c:px(48, 54, CUT[6]) c:px(47, 54, CUT[5])
G.fin(c, "turmeric")
