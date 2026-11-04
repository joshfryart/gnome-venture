-- stage-spice-1 (lean W2_24)
-- Spice seedling: a plump green seed pod lying split on a soil patch, a thin stem with heart-shaped first leaves, one spice seed rolling beside it (quirk: seed wears a tiny leaf hat).
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-spice-1" }
soil(c, 32, 52, 23, 6)
-- pod: banana-curved from two ovals
local pod = HP.mask()
pod:add(blob(23, 44, 12, 5.5, -0.22)) pod:add(blob(40, 44, 10, 4.5, 0.35))
local pv, pn = shade(c, pod, 6, LEAF)
-- seam line along the pod
for x = 13, 49 do local y = floor(41 + 0.06 * (x - 13) + 0.5)
  if pod:has(x, y) then c:px(x, y, LEAF[2]) end end
for _, p in ipairs{ {18,40},{19,40},{20,39} } do c:px(p[1], p[2], "#e9f7b4") end
-- stem and heart leaves
local sm, sn = G.tube({ {36, 41}, {36, 36}, {35, 31}, {35, 26} }, function(t) return 1.0 end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), LEAF, { 0.3, 0.5, 0.7, 0.88, 0.95 })
local function heart(cx, cy, s, a)
  local m = HP.mask()
  m:add(blob(cx - s * 0.55, cy, s * 0.6, s * 0.75, a)) m:add(blob(cx + s * 0.55, cy, s * 0.6, s * 0.75, -a))
  m:add(HP.mask():add(c:poly{ {cx - s, cy + 1}, {cx + s, cy + 1}, {cx, cy + s * 1.5} }))
  shade(c, m, 3, LEAF)
  c:px(cx, cy - 1, LEAF[2]) c:px(cx, cy, LEAF[2]) c:px(cx, cy + 1, LEAF[2])
  c:px(cx - 2, cy - 1, LEAF[6])
end
heart(30, 24, 4, 0.5)
heart(41, 21, 3.5, -0.5)
-- spice seed with leaf hat
local sd = blob(11, 41, 3.8, 3.2, 0.4)
shade(c, sd, 3, BARK)
c:px(9, 39, BARK[6]) c:px(10, 39, BARK[6]) c:px(13, 43, BARK[1])
c:fillMask(c:rect(9, 37, 12, 37), LEAF[3]) c:px(10, 36, LEAF[5]) c:px(11, 36, LEAF[4])
G.fin(c, "stage-spice-1")
