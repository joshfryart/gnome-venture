-- stage-cover-2 (lean D2o_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-cover-2" }
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
-- four clover clumps, trifoliate heads with pale chevrons
local function clover(x, h, r)
  local sm, sn = G.tube({ {x, 46}, {x - 1, 46 - h * 0.4}, {x + 1, 46 - h * 0.75}, {x, 46 - h} }, function(t) return 0.9 end)
  tshade(sm, sn, LEAF, { cuts = { 0.3, 0.5, 0.65, 0.8, 0.92 } })
  local tx, ty = x, 46 - h
  local leaves = { {tx - r * 0.95, ty - r * 0.15}, {tx + r * 0.95, ty - r * 0.15}, {tx, ty - r * 1.0} }
  for _, p in ipairs(leaves) do
    local lm = G.rell(p[1], p[2], 0, 1, r, r * 0.92)
    local tm = c:ellipse(p[1], p[2], r * 0.95, r * 0.9)
    shade(lm:add(tm), LEAF, 3)
    local cx, cy = floor(p[1]), floor(p[2])
    c:px(cx - 1, cy, LEAF[6]) c:px(cx, cy + 1, LEAF[6]) c:px(cx + 1, cy, LEAF[6])
  end
end
clover(15, 12, 3.2)
clover(50, 13, 3.3)
clover(25, 18, 3.6)
clover(39, 20, 3.8)
-- quirk: one pink clover blossom
local fl = c:ellipse(33, 21, 2.6, 2.6)
shade(fl, { "#7a1f4a", "#a63a6a", "#d4608a", "#f090aa", "#ffc4cf", "#fff0f0" }, 3)
c:px(33, 21, "#ffe36a")
G.fin(c, "stage-cover-2")
