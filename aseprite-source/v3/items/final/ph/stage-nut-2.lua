-- stage-nut-2 (lean E2_11)
local NAME = "stage-nut-2"
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

-- quirk: a single baby acorn dangles from a hair-thin stalk
local OAKS = { "#1a4a30", "#256b3c", "#37904a", "#55b458", "#80d268", "#b8ee88" }
soil(18)
tube({ {32,53},{31,43},{35,33},{32,15} }, function(t) return 1.8 - 0.8 * t end, BARK, "trunk")
tube({ {31,43},{27,41},{23,39},{20,40} }, function(t) return 0.7 end, BARK, "tw1")
tube({ {34,33},{38,32},{42,31},{46,31} }, function(t) return 0.7 end, BARK, "tw2")
local lo = { lobe = 0.4, lobes = 5, veins = { 3, 6, 9 } }
leaf(30, 41, 21, 35, 11, 40, 5, OAKS, "a", lo)
leaf(35, 33, 45, 27, 55, 32, 5, OAKS, "b", lo)
leaf(33, 26, 24, 20, 14, 22, 5, OAKS, "c", lo)
leaf(33, 21, 42, 14, 52, 15, 5, OAKS, "d", lo)
leaf(32, 16, 27, 10, 33, 6, 4, OAKS, "e", lo)
c:line({ {38,32},{38,36} }, 1):each(function(x, y) c:put(x, y, BARK[3], { r = { name = "st" } }) end)
acorn(38, 40, 1.15)
G.save(c, NAME)
