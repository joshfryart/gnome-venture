-- stage-nut-3 (lean E2_11)
local NAME = "stage-nut-3"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.54, 0.7, 0.85 }
local LEAF = { "#163a35", "#1f5a40", "#2f7f48", "#47a24f", "#6cc25a", "#a2de6c" }
local SOIL = { "#2a1a1c", "#4a2e26", "#6e4630", "#8f6038", "#b07c48", "#cf9c60" }
local BARK = { "#2e1a1a", "#4a2c24", "#6b4230", "#8a5a3c", "#a87650", "#c79a6c" }
local ACOR = { "#4a2a18", "#7a4824", "#a8682e", "#cc8c42", "#e8b05c", "#f8d488" }
local CAPR = { "#2e1a14", "#4e3022", "#6e4a30", "#8c6642", "#a8825a", "#c8a678" }
local GLINT = "#fff4d0"
local function U(list) local m = list[1]:copy() for i = 2, #list do m:add(list[i]) end return m end
local function vol(m, ramp, R, nm, o)
  o = o or {}
  local n = X.pillow(m, R or 3)
  local idx = X.tone(c, m, X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 }), ramp, { cuts = CUTS, tok = { r = { name = nm or "p" } } })
  return idx, n
end
local function tube(pts, fn, ramp, nm)
  local m, n, T = G.tube(pts, fn)
  G.toneN(c, m, n, ramp, { tok = { r = { name = nm } }, cuts = CUTS, amb = 0.12, wrap = 0.3 })
  return m, n, T
end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, nm, o)
  o = o or {}
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    local r = w * sin(pi * u ^ (o.p or 1.2)) ^ (o.q or 0.75)
    if o.lobe then r = r * (1 + o.lobe * sin(t * pi * o.lobes)) end
    return max(0.5, r)
  end, { fold = o.fold or 0.45 })
  local tok = { r = { name = nm } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tok) return end
    if o.veins then for _, vt in ipairs(o.veins) do
      local d = t * L - (vt + abs(s) * 3.4)
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.72 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tok) return end
    end end
  end)
  return m
end
local function soil(rx)
  local m = c:ellipse(32, 54, rx or 20, 4.6)
  local idx = vol(m, SOIL, 5, "soil")
  m:each(function(x, y)
    local h = X.hash(x, y, 7)
    if h > 0.9 then c:put(x, y, SOIL[6], { r = { name = "soil" } }) elseif h < 0.07 then c:put(x, y, SOIL[1], { r = { name = "soil" } }) end
  end)
  return m
end
local function acorn(x, y, s)
  s = s or 1
  local b = c:ellipse(x, y + 1, 1.9 * s, 2.4 * s)
  vol(b, ACOR, 2, "ac")
  local cp = c:ellipse(x, y - 1, 2.5 * s, 1.5 * s)
  vol(cp, CAPR, 1.5, "ac")
  c:put(floor(x - 1 * s), floor(y + 1), GLINT, { r = { name = "ac" } })
end

-- quirk: a little red toadstool grows between the roots; acorns hang in the crown
soil(21)
local function lobe(cx, cy, rx, ry, nm)
  local m = c:ellipse(cx, cy, rx, ry)
  local idx = vol(m, LEAF, max(rx, ry) * 0.9, nm)
  m:each(function(x, y) local h = X.hash(x, y, 11)
    if h > 0.93 then c:put(x, y, LEAF[min(6, (idx[K(x, y)] or 3) + 1)], { r = { name = nm } }) elseif h < 0.05 then c:put(x, y, LEAF[max(1, (idx[K(x, y)] or 3) - 1)], { r = { name = nm } }) end end)
end
lobe(22, 19, 10, 8, "b1") lobe(42, 19, 10, 8, "b2") lobe(32, 12, 11, 7, "b3")
-- trunk
local tr = c:poly{ {25,54},{29,46},{29,28},{35,28},{35,46},{40,54} }
vol(tr, BARK, 4, "trunk")
for _, p in ipairs{ {31,36},{31,37},{33,42},{33,43},{32,48} } do c:put(p[1], p[2], BARK[1], { r = { name = "trunk" } }) end
lobe(19, 28, 8, 6, "f1") lobe(45, 28, 8, 6, "f2") lobe(32, 26, 12, 7, "f3")
acorn(21, 36, 1.0) acorn(42, 36, 1.0) acorn(33, 34, 1.0)
-- toadstool
vol(c:rect(18, 51, 19, 53), { "#a89472", "#c8b690", "#e2d2b4", "#f0e4c8", "#f6ecd6", "#fffaea" }, 1, "mst")
vol(c:ellipse(18.5, 50, 3.6, 2.2), { "#5a1420", "#8a2030", "#b8303c", "#d8503c", "#f08060", "#ffb090" }, 2.5, "mcap")
c:put(17, 49, "#fff4e0", { r = { name = "mcap" } }) c:put(20, 50, "#fff4e0", { r = { name = "mcap" } })
G.save(c, NAME)
