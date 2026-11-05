-- ginseng (lean E2_01)
local NAME = "ginseng"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, ceil = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.ceil
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function inter(a, b) local r = HP.mask() a:each(function(x, y) if b:has(x, y) then r:set(x, y) end end) return r end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ROOT = { "#6a4a3a", "#9a7a5a", "#c4a47a", "#e0c8a0", "#f0dfbc", "#faf0d6" }
local GL = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local RED = { "#5a0f20", "#8c1c2c", "#c4303c", "#e8584c", "#ff8a6a" }
c:groundShadow(32, 58, 12, 2.5)
local function tube(pts, fn, ramp, tag, rings)
  local m, n = G.tube(pts, fn)
  local tok = { r = { name = tag } }
  local idx = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, { cuts = CUTS, tok = tok })
  if rings then m:each(function(x, y) local k = K(x, y)
    if y % 4 == 0 and X.hash(x, y, 3) > 0.3 then c:put(x, y, ramp[max(1, idx[k] - 1)], tok) end end) end
  return m
end
-- limbs first, body over
local lg1 = tube({ {30,42}, {27,48}, {25,52}, {22,57} }, function(t) return 2.3 - 1.3 * t end, ROOT, "legL", true)
local lg2 = tube({ {32,42}, {36,48}, {38,52}, {42,57} }, function(t) return 2.3 - 1.3 * t end, ROOT, "legR", true)
tube({ {29,32}, {23,33}, {19,35}, {15,41} }, function(t) return 2.1 - 1.1 * t end, ROOT, "armL", true)
tube({ {35,32}, {41,33}, {45,35}, {49,41} }, function(t) return 2.1 - 1.1 * t end, ROOT, "armR", true)
tube({ {32,26}, {32,32}, {31,38}, {31,45} }, function(t) return 4.6 - 1.2 * t end, ROOT, "body", true)
-- rootlet hairs
local htok = { r = { name = "hair" } }
for _, h in ipairs{ {{22,57},{20,60}}, {{22,57},{23,60}}, {{42,57},{41,60}}, {{42,57},{44,60}}, {{15,41},{13,44}}, {{49,41},{51,44}} } do
  c:line(h, 1):each(function(x, y) c:put(x, y, ROOT[2], htok) end)
end
-- crown scar
local crown = c:ellipse(32, 26, 3.4, 2.2)
X.tone(c, crown, X.light(X.pillow(crown, 2), { amb = 0.1, wrap = 0.2 }), { "#3a241c", "#5e3a2a", "#8a5a3a", "#b07c4c" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "crown" } } })
-- stem
local stm = tube({ {32,25}, {32,23}, {32,21}, {32,18} }, function(t) return 1.2 end, GL, "stem", false)
-- four leaflets
local function leaflet(ex, ey, cx, cy, tag)
  local m, n, T, S, L = G.blade(32, 19, cx, cy, ex, ey, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 3.6 * sin(pi * (min(1, t * 0.9 + 0.1))) ^ 0.75)
  end, { fold = 0.4 })
  local tok = { r = { name = tag } }
  X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), GL, { cuts = CUTS, tok = tok })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.05 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and GL[6] or GL[2], tok) end end)
end
leaflet(12, 19, 21, 13, "l1") leaflet(20, 8, 27, 9, "l2") leaflet(44, 8, 37, 9, "l3") leaflet(52, 19, 43, 13, "l4")
-- red berry cluster
c:line({ {32,19}, {32,14} }, 1):each(function(x, y) c:put(x, y, GL[4], { r = { name = "stalk" } }) end)
for i, b in ipairs{ {30,13}, {34,13}, {32,10} } do
  local bm = c:ellipse(b[1], b[2], 2.4, 2.4)
  local t = { r = { name = "berry" .. i } }
  X.tone(c, bm, X.light(X.pillow(bm, 2), { amb = 0.06, wrap = 0.2 }), RED, { cuts = { 0.25, 0.5, 0.75, 0.9 }, tok = t })
  c:put(b[1] - 1, b[2] - 1, "#ffd0c0", t)
end
G.save(c, NAME)
