-- stage-cover-3 (lean D2o_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-cover-3" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function tshade(m, n, ramp, o) o = o or {}
  local v = X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return v
end
local SOIL = { "#2a1a1c", "#46291f", "#6b3f28", "#8f5a36", "#b47e4c", "#d5a468" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 55, 22, 3)
local mound = c:ellipse(32, 49, 23, 7):add(c:ellipse(32, 45, 17, 6))
local sb = {}
X.ao(sb, mound, c:rect(0, 0, 0, 0), 2, 0)
shade(mound, SOIL, 9)
mound:each(function(x, y) if X.hash(x, y, 5) > 0.9 then c:px(x, y, SOIL[5]) elseif X.hash(x, y, 8) > 0.93 then c:px(x, y, SOIL[1]) end end)
for _, p in ipairs{ {18,49},{24,53},{40,52},{47,48},{34,50} } do c:px(p[1], p[2], SOIL[6]) c:px(p[1] + 1, p[2], SOIL[4]) c:px(p[1], p[2] + 1, SOIL[1]) end
-- lush fan of broad leaves with midribs + one flower bud
local function bigleaf(x0, x1, y1, w, c1)
  local lm, ln, T, S = G.tube({ {32 + (x0 - 32) * 0.2, 46}, {x0, 40}, {x1 - (x1 - x0) * 0.2, y1 + 8}, {x1, y1} },
    function(t) return max(0.7, w * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.7) end)
  local v = tshade(lm, ln, LEAF, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  lm:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.15 and T[k] < 0.92 then c:px(x, y, S[k] <= 0 and LEAF[6] or LEAF[4]) end
    for _, vt in ipairs{ 0.35, 0.5, 0.65, 0.8 } do
      local d = (T[k] - vt) * 22 - abs(S[k]) * 2.4
      if d > -0.5 and d < 0.5 and abs(S[k]) > 0.3 and abs(S[k]) < 0.8 then c:px(x, y, S[k] < 0 and LEAF[5] or LEAF[2]) end
    end
  end)
end
bigleaf(14, 8, 24, 5.2)
bigleaf(50, 57, 25, 5.2)
bigleaf(20, 15, 14, 4.8)
bigleaf(44, 49, 15, 4.8)
bigleaf(26, 25, 9, 4.2)
bigleaf(38, 40, 10, 4.2)
-- centre stalk + bud
local sm, sn = G.tube({ {32, 46}, {32, 36}, {31, 28}, {32, 20} }, function(t) return 1.3 end)
tshade(sm, sn, LEAF)
local bud = c:ellipse(32, 17, 4, 4.8)
shade(bud, { "#7a1f4a", "#a63a6a", "#d4608a", "#f090aa", "#ffc4cf", "#fff0f0" }, 4)
for _, p in ipairs{ {32,14},{32,15},{32,16} } do c:px(p[1], p[2], "#a63a6a") end
c:px(30, 15, "#fff8f0") c:px(32, 21, LEAF[3]) c:px(30, 21, LEAF[4]) c:px(34, 21, LEAF[2])
G.fin(c, "stage-cover-3")
