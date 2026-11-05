-- stage-legume-4 (lean E2_11)
local NAME = "stage-legume-4"
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

-- quirk: one pod has split open to show its plump pale beans
local PODG = { "#1b4a2c", "#2a6a38", "#3f8a40", "#62a84c", "#8cc860", "#bce088" }
soil(20)
tube({ {32,53},{31,42},{33,32},{32,20} }, function(t) return 1.9 - 0.5 * t end, PODG, "stem")
leaf(32, 22, 20, 10, 8, 14, 6, LEAF, "L1", { veins = { 4, 8, 12 } })
leaf(32, 22, 44, 10, 56, 14, 6, LEAF, "L2", { veins = { 4, 8, 12 } })
leaf(32, 22, 31, 14, 32, 6, 4.5, LEAF, "L3", { veins = { 4, 8 } })
-- closed pod left
local pm = tube({ {31,24},{19,22},{14,34},{20,47} }, function(t) return (1.9 + 0.55 * sin(t * pi * 6)) * (1 - 0.45 * t ^ 3) end, { "#4a5a14", "#6a8a24", "#8cb034", "#aed048", "#cce670", "#ecfa9c" }, "podL")
-- open pod right
local om = tube({ {33,24},{45,22},{50,34},{44,47} }, function(t) return 2.5 * (1 - 0.4 * t ^ 3) end, { "#4a5a14", "#6a8a24", "#8cb034", "#aed048", "#cce670", "#ecfa9c" }, "podR")
local bp = { {47,28},{49,33},{49,38},{46,43} }
for i, p in ipairs(bp) do
  vol(c:ellipse(p[1], p[2], 1.9, 2.0), { "#6a5a28", "#a8924a", "#cdb468", "#e6d488", "#f6ecb0", "#fffbe0" }, 1.8, "bean" .. i)
end
G.save(c, NAME)
