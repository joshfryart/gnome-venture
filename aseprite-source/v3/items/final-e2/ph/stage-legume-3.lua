-- stage-legume-3 (lean E2_11)
local NAME = "stage-legume-3"
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

-- quirk: a pink pea flower and a curly tendril grabbing at air
local PODG = { "#1b4a2c", "#2a6a38", "#3f8a40", "#62a84c", "#8cc860", "#bce088" }
soil(20)
-- bamboo stake
local sm, sn, ST = tube({ {44,53},{44,40},{44,22},{44,7} }, function(t) return 1.7 end, { "#5a4020", "#7e5c2c", "#a4803c", "#c8a458", "#e4c878", "#f6e4a0" }, "stake")
for _, y in ipairs{ 17, 29, 41 } do for x = 42, 46 do if sm:has(x, y) then c:put(x, y, "#4a3418", { r = { name = "stake" } }) end end end
-- vine winding up
tube({ {30,52},{30,42},{38,40},{45,34} }, function(t) return 1.2 end, PODG, "v1")
tube({ {45,34},{55,31},{53,22},{43,20} }, function(t) return 1.2 end, PODG, "v2")
tube({ {43,20},{33,18},{36,10},{46,8} }, function(t) return 1.1 - 0.3 * t end, PODG, "v3")
-- trifoliate leaves
local function tri(x, y, dx, dy, s)
  leaf(x, y, x + dx * 0.5 - dy * 0.3, y + dy * 0.5 + dx * 0.3, x + dx, y + dy, 3.6 * s, LEAF, "t" .. x .. y .. dx, { veins = { 3, 6 } })
end
tri(30, 42, -14, -3, 1) tri(30, 42, -9, -13, 1) tri(30, 42, -10, 5, 0.9)
tri(54, 30, 5, -9, 1) tri(54, 29, 4, 4, 0.9)
tri(36, 15, -11, -3, 1) tri(36, 14, -3, -9, 0.9)
-- flower
local PET, PETD = "#f4a8c4", "#c46a96"
for i = 0, 4 do
  local a = i * 2 * pi / 5 - pi / 2
  local fx, fy = 55 + cos(a) * 2.6, 44 + sin(a) * 2.6
  vol(c:ellipse(fx, fy, 1.8, 1.8), { "#8a3a6a", PETD, "#e07ca8", PET, "#fcc8dc", "#ffe8f0" }, 1.5, "pet" .. i)
end
c:put(55, 44, "#f8d24a", { r = { name = "fc" } })
-- tendril
c:line({ {52,22},{57,19},{59,23},{56,25},{55,22} }, 1):each(function(x, y) c:put(x, y, "#6cc25a", { r = { name = "tend" } }) end)
-- twine
for _, p in ipairs{ {42,35},{43,35},{44,35},{45,35},{46,35} } do c:put(p[1], p[2], "#d8584a", { r = { name = "tw" } }) end
G.save(c, NAME)
