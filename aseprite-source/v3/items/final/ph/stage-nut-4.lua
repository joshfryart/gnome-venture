-- stage-nut-4 (lean E2_11)
local NAME = "stage-nut-4"
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

-- quirk: a wise round-eyed owl peers out of the hollow in the great trunk
soil(24)
local function lobe(cx, cy, rx, ry, nm)
  local m = c:ellipse(cx, cy, rx, ry)
  local idx = vol(m, LEAF, max(rx, ry) * 0.9, nm)
  m:each(function(x, y) local h = X.hash(x, y, 13)
    if h > 0.93 then c:put(x, y, LEAF[min(6, (idx[K(x, y)] or 3) + 1)], { r = { name = nm } }) elseif h < 0.05 then c:put(x, y, LEAF[max(1, (idx[K(x, y)] or 3) - 1)], { r = { name = nm } }) end end)
end
lobe(24, 13, 11, 8, "b1") lobe(40, 13, 11, 8, "b2") lobe(32, 8, 10, 5, "b3")
-- limbs
tube({ {27,38},{22,34},{17,32},{12,29} }, function(t) return 2.2 - 1.0 * t end, BARK, "limL")
tube({ {37,38},{42,34},{47,32},{52,29} }, function(t) return 2.2 - 1.0 * t end, BARK, "limR")
lobe(13, 22, 8, 7, "s1") lobe(51, 22, 8, 7, "s2")
-- trunk with root flare
local tr = c:poly{ {17,55},{23,50},{25,44},{25,34},{39,34},{39,44},{41,50},{47,55} }
local ti = vol(tr, BARK, 8, "trunk")
for _, p in ipairs{ {28,36},{28,37},{28,38},{36,36},{36,37},{35,50},{35,51},{26,50},{27,51},{27,45},{27,46} } do if tr:has(p[1], p[2]) then c:put(p[1], p[2], BARK[1], { r = { name = "trunk" } }) end end
for _, p in ipairs{ {37,40},{38,41},{37,46},{38,47} } do c:put(p[1], p[2], "#5a8a3c", { r = { name = "moss" } }) end
lobe(32, 22, 14, 8, "f3") lobe(21, 29, 8, 5, "f1") lobe(43, 29, 8, 5, "f2")
-- hollow with owl
local hol = c:ellipse(32, 44, 4.5, 5.5)
vol(hol, { "#120a10", "#1e1218", "#2a1a22", "#3a2630", "#4a323c", "#5a4250" }, 6, "hollow", { amb = 0.0 })
for _, p in ipairs{ {30,42},{31,42},{30,43},{31,43},{33,42},{34,42},{33,43},{34,43} } do c:put(p[1], p[2], "#ffd84a", { r = { name = "eye" } }) end
c:put(30, 42, "#fff6c0", { r = { name = "eye" } }) c:put(33, 42, "#fff6c0", { r = { name = "eye" } })
c:put(31, 43, "#2b1c26", { r = { name = "eye" } }) c:put(34, 43, "#2b1c26", { r = { name = "eye" } })
c:put(32, 45, "#e8803a", { r = { name = "beak" } })
acorn(14, 31, 1.0) acorn(50, 31, 1.0) acorn(26, 31, 1.0) acorn(38, 31, 1.0)
G.save(c, NAME)
