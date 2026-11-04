-- stage-cover-1 (lean D2o_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-cover-1" }
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
-- three seedlings: slim stalk + cotyledon pair
local function sprout(x, h, lean, big)
  local sm, sn = G.tube({ {x, 46}, {x, 46 - h * 0.4}, {x + lean * 0.6, 46 - h * 0.8}, {x + lean, 46 - h} }, function(t) return 1.1 - 0.2 * t end)
  tshade(sm, sn, LEAF, { cuts = { 0.3, 0.5, 0.65, 0.8, 0.92 } })
  local tx, ty = x + lean, 46 - h
  for _, s in ipairs{ -1, 1 } do
    local ang = s * 0.35
    local cm = G.rell(tx + s * big * 0.9, ty - 0.5 - s * 0.0, cos(ang) * s, -sin(abs(ang)) * 0.8, big, big * 0.62)
    shade(cm, LEAF, 3)
    c:px(floor(tx + s * big * 0.5), floor(ty - 1), LEAF[6])
  end
  c:px(tx, ty - 1, LEAF[3]) c:px(tx, ty - 2, LEAF[4])
  c:px(tx, ty - 3, LEAF[5])
end
sprout(19, 12, -1, 3.6)
sprout(45, 14, 2, 3.8)
sprout(32, 20, 1, 4.6)
c:px(26, 44, "#c9a070") c:px(38, 44, "#c9a070") c:px(27, 44, "#8f5a36")  -- husk crumbs
G.fin(c, "stage-cover-1")
