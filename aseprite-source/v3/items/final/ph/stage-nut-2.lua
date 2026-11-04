-- stage-nut-2 (lean W2_24)
-- Young nut sapling: slim bent trunk, three small leaf puffs, half-buried acorn shell at its foot (quirk: shell still wears its cap).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function blob(cx, cy, rx, ry, ang)
  local m = HP.mask(); local ca, sa = cos(ang or 0), sin(ang or 0)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x + 0.5 - cx, y + 0.5 - cy
    local u, w = (dx * ca + dy * sa) / rx, (-dx * sa + dy * ca) / ry
    if u * u + w * w <= 1 then m:set(x, y) end
  end end
  return m
end
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local function shade(c, m, R, ramp, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, CUTS, bias, tok)
  return v, n
end
local SOIL = { "#2e1d1f", "#47291f", "#69391f", "#8a5128", "#ad6c33", "#cf8f4a" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a6d36e" }
local BARK = { "#2f1d22", "#4a2c26", "#6b4129", "#8d5b34", "#b07c47", "#d1a063" }
local function soil(c, cx, cy, rx, ry)
  c:groundShadow(cx, cy + 2, rx + 2, ry)
  local m = blob(cx, cy, rx, ry)
  shade(c, m, ry + 1, SOIL)
  m:each(function(x, y) local h = X.hash(x, y, 3)
    if h > 0.93 and y > cy - ry + 2 then c:px(x, y, SOIL[6]) elseif h < 0.05 then c:px(x, y, SOIL[1]) end end)
  return m
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-nut-2" }
soil(c, 32, 51, 20, 7)
-- trunk
local tm, tn = G.tube({ {31, 48}, {30, 40}, {34, 34}, {33, 26} }, function(t) return 2.2 - 1.3 * t end)
G.tone(c, tm, X.light(tn, { amb = 0.15, wrap = 0.3 }), BARK, { 0.3, 0.5, 0.7, 0.88 })
-- side twig
local wm, wn = G.tube({ {33, 38}, {37, 36}, {40, 33}, {41, 30} }, function(t) return 1.0 end)
G.tone(c, wm, X.light(wn, { amb = 0.15, wrap = 0.3 }), BARK, { 0.3, 0.5, 0.7, 0.88 })
-- canopy puffs (back to front)
local function puff(cx, cy, rx, ry, a)
  local m = blob(cx, cy, rx, ry, a)
  local v = shade(c, m, 5, LEAF)
  m:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 9)
    if h > 0.88 and v[k] > 0.5 then c:px(x, y, LEAF[6]) elseif h < 0.1 and v[k] < 0.6 then c:px(x, y, LEAF[2]) end end)
  c:px(floor(cx - rx * 0.4), floor(cy - ry * 0.5), LEAF[6])
  return m
end
puff(40, 27, 6, 5, 0.3)
puff(25, 28, 7, 5, -0.3)
puff(33, 19, 9, 7, 0)
-- acorn half buried, with cap and a tiny curled root
local ac = blob(46, 49, 4.5, 3.5, -0.3)
shade(c, ac, 3, BARK)
local cap = HP.mask() cap:add(ac) cap:cut(c:rect(0, 49, 63, 63))
c:fillMask(cap:copy():shrink(0), BARK[4])
c:fillMask(c:rect(43, 46, 49, 46), BARK[2])
c:px(44, 47, BARK[6]) c:px(45, 46, BARK[6])
c:px(41, 51, "#e9d9a5") c:px(40, 52, "#e9d9a5")
-- sprout leaf pair at acorn shell: tiny
c:px(46, 45, LEAF[4]) c:px(47, 44, LEAF[5])
G.fin(c, "stage-nut-2")
