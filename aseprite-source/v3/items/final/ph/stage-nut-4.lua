-- stage-nut-4 (lean W2_24)
-- Mature nut tree: fat flared trunk with a knothole that has two peeking eyes (quirk), big layered canopy hung with acorns.
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-nut-4" }
soil(c, 32, 54, 24, 6)
-- trunk with flared roots
local tm = HP.mask()
for y = 30, 54 do
  local t = (y - 30) / 24
  local h = 4.5 + 5 * t ^ 3.2
  for x = floor(32 - h), floor(32 + h) do tm:set(x, y) end
end
local tn = X.pillow(tm, 6)
local tv = X.light(tn, { amb = 0.08, wrap = 0.2 })
G.tone(c, tm, tv, BARK, { 0.2, 0.4, 0.6, 0.8 })
tm:each(function(x, y) if (x % 4 == 1) and X.hash(x, y, 2) > 0.45 and y % 6 < 4 then c:px(x, y, BARK[2]) end end)
-- knothole + eyes
c:fillMask(blob(32, 44, 2.6, 3.4), BARK[1])
c:px(31, 43, "#fff6d8") c:px(33, 43, "#fff6d8")
-- canopy
local can = HP.mask()
local blobs = { {17, 26, 9, 7}, {47, 26, 9, 7}, {32, 14, 12, 9}, {24, 18, 9, 8}, {41, 18, 9, 8}, {32, 27, 13, 7} }
for _, b in ipairs(blobs) do can:add(blob(b[1], b[2], b[3], b[4])) end
local bias = {}
X.ao(bias, can, tm, 2, -1)
local v = shade(c, can, 9, LEAF, bias)
can:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 7)
  if h > 0.9 and v[k] > 0.45 then c:px(x, y, LEAF[6]) elseif h < 0.09 and v[k] < 0.7 then c:px(x, y, LEAF[2]) end end)
-- scalloped leaf-edge highlights
for _, p in ipairs{ {14,21},{22,12},{30,8},{38,9},{45,13},{50,20} } do c:px(p[1], p[2], LEAF[6]) c:px(p[1] + 1, p[2], LEAF[5]) end
-- acorns
local function acorn(x, y)
  local a = blob(x, y + 1, 2.3, 2.9)
  shade(c, a, 2, BARK)
  c:fillMask(c:rect(x - 3, y - 2, x + 2, y - 1), LEAF[2])
  c:fillMask(c:rect(x - 2, y - 3, x + 1, y - 3), LEAF[3])
  c:px(x - 1, y + 1, BARK[6])
end
acorn(15, 33) acorn(26, 35) acorn(39, 35) acorn(50, 33) acorn(32, 20)
G.fin(c, "stage-nut-4")
