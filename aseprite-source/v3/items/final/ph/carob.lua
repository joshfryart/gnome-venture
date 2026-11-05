-- carob (lean P1pilot)
local NAME = "carob"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = { r = { name = nm } } if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local POD = { "#1f0e0c", "#3e1c14", "#6a3220", "#8f4a2c", "#b26a3c", "#d9955a" }
local LEAF = { "#14352e", "#1f5a3c", "#2e8046", "#4aa44e", "#7cc860", "#b4e888" }
local SEED = { "#2a1410", "#4a2218", "#6e3a22", "#94562e" }
-- twig
local tm, tn = G.tube({ {50,8}, {46,10}, {42,12}, {38,14} }, function(t) return 1.1 end)
G.toneN(c, tm, tn, { "#3a2214", "#5e3a20", "#86582c", "#a87c40" }, { tok = { r = { name = "twig" } }, cuts = {0.3,0.55,0.8} })
-- leaflets (round, glossy)
local function leaflet(cx, cy, rx, ry, nm)
  local m = c:ellipse(cx, cy, rx, ry)
  ball(m, 3.5, LEAF, nm, { amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) if abs(x - cx) < 1 and abs(y - cy) < ry - 1 then c:put(x, y, LEAF[6], { r = { name = nm } }) end end)
end
leaflet(54, 5, 4, 3, "l1") leaflet(48, 4, 3, 3, "l2") leaflet(56, 12, 3, 3, "l3") leaflet(42, 6, 3, 3, "l4")
-- pod: long curved bean, hangs from twig, bows left
local pm, pn, PT = G.tube({ {40,13}, {18,20}, {13,40}, {24,56} }, function(t) return 5.2 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.5 + 1.0 end)
local bias = {}
G.toneN(c, pm, pn, POD, { tok = { r = { name = "pod" } }, cuts = {0.2,0.38,0.56,0.74,0.88}, amb = 0.06, wrap = 0.18 })
-- leathery wrinkles across the pod
pm:each(function(x, y) local k = K(x, y) local t = PT[k]
  if floor(t * 38 + (x % 2) * 0.5) % 4 == 0 and X.hash(x, y, 8) > 0.35 then c:put(x, y, POD[2], { r = { name = "pod" } }) end end)
-- seed ridge line along the outer edge
pm:edge():each(function(x, y) if x < 22 and y > 24 then c:put(x, y, POD[1], { r = { name = "pod" } }) end end)
-- cut window showing seeds (pod snapped open near lower end)
local win = c:ellipse(19, 47, 4, 6):clip(pm)
win:each(function(x, y) c:put(x, y, "#e8c98a", { r = { name = "pulp" } }) end)
win:shrink(1):each(function(x, y) c:put(x, y, "#c9954e", { r = { name = "pulp" } }) end)
for _, s in ipairs{ {19,44}, {18,48}, {19,52} } do
  local m = c:ellipse(s[1], s[2], 2, 1)
  m:each(function(x, y) c:put(x, y, SEED[(x < s[1]) and 4 or 3], { r = { name = "seed" } }) end)
  c:put(s[1] - 1, s[2] - 1, "#c88a5a", { r = { name = "seed" } })
end
-- spec streak
for _, p in ipairs{ {26,17},{25,17},{24,18},{20,21},{19,22},{16,28},{15,30},{14,34} } do if pm:has(p[1], p[2]) then c:put(p[1], p[2], POD[6], { r = { name = "pod" } }) end end
for _, p in ipairs{ {16,29},{15,32} } do c:put(p[1], p[2], "#ffd9a4", { r = { name = "pod" } }) end
G.save(c, NAME)
