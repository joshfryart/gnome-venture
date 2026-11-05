-- stage-nut-4 (lean P1b_O11)
local NAME = "stage-nut-4"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = { r = { name = nm } } if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local BL = { "#143a2c", "#20603a", "#38884a", "#5cae54", "#8ed068", "#c4ee90" }
local GOLD = { "#6a3c10", "#a2641a", "#d49a2a", "#f0c446", "#ffe27a", "#fff4b8" }
local BARK = { "#2a1a1c", "#4a2e26", "#6e4630", "#946238", "#bc8a50" }
local function base()
  c:groundShadow(32, 56, 24, 3)
  local soil = c:ellipse(32, 50, 22, 7)
  soil:add(c:ellipse(32, 47, 15, 6))
  ball(soil, 9, SOIL, "soil", { amb = 0.1, wrap = 0.2 })
  soil:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:put(x, y, SOIL[5], { r = { name = "soil" } }) elseif h < 0.07 then c:put(x, y, SOIL[1], { r = { name = "soil" } }) end end)
  for _, p in ipairs{ {16,52},{17,52},{48,52},{49,52},{47,53} } do c:put(p[1], p[2], "#b8a898", { r = { name = "pb" } }) end
  for _, p in ipairs{ {18,53},{50,53} } do c:put(p[1], p[2], "#6a5a60", { r = { name = "pb" } }) end
end
local function blade(ax, ay, cx, cy, bx, by, w, nm, ramp, rib)
  ramp = ramp or BL
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.985 then return -1 end return max(0.5, w * (1 - t) ^ 0.7 + 0.3) end, { fold = 0.5 })
  local tok = { r = { name = nm } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = {0.18,0.34,0.5,0.66,0.82}, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and ramp[6] or ramp[2], tok) end end)
  return m
end
local function oval(cx, cy, rx, ry, ramp, nm) local m = c:ellipse(cx, cy, rx, ry) ball(m, max(rx, ry) + 0.5, ramp, nm) return m end
local function stalk(p, w, ramp, nm)
  local m, n = G.tube(p, function(t) return w end)
  G.toneN(c, m, n, ramp, { tok = { r = { name = nm } }, cuts = {0.3,0.55,0.8}, amb = 0.12, wrap = 0.25 })
  return m
end
base()
local LF = { "#143a2c", "#24663c", "#3e9448", "#64bc58", "#98dc70", "#ccf4a0" }
-- thick trunk with flared roots
local tr = c:poly{ {26,50},{28,44},{28,34},{36,34},{36,44},{39,50},{34,52},{30,52} }
local tn = X.pillow(tr, 7)
G.toneN(c, tr, tn, BARK, { tok = { r = { name = "trunk" } }, cuts = {0.2,0.4,0.58,0.76,0.9}, amb = 0.08, wrap = 0.15 })
tr:each(function(x, y) if (x * 3 + y) % 7 == 0 and y < 48 and X.hash(x, y, 3) > 0.3 then c:put(x, y, BARK[2], { r = { name = "trunk" } }) end end)
-- big layered canopy
local function crown(cx, cy, rx, ry, nm)
  local m = c:ellipse(cx, cy, rx, ry)
  ball(m, max(rx, ry) + 2, LF, nm, { amb = 0.08, wrap = 0.2 })
  m:each(function(x, y) local h = X.hash(x, y, 9) if h > 0.9 then c:put(x, y, LF[6], { r = { name = nm } }) elseif h < 0.1 then c:put(x, y, LF[1], { r = { name = nm } }) end end)
end
crown(32, 14, 13, 9, "c1")
crown(17, 24, 11, 8, "c2")
crown(47, 24, 11, 8, "c3")
crown(32, 26, 12, 8, "c4")
-- hanging acorns
for _, p in ipairs{ {14,33},{50,33},{24,35},{41,35} } do
  local ac = c:ellipse(p[1], p[2], 1.6, 2.4)
  G.toneN(c, ac, X.pillow(ac, 2.5), { "#6a4018", "#a2682c", "#d49a48", "#f0c880" }, { tok = { r = { name = "ac" } }, cuts = {0.3,0.6,0.85} })
  c:put(p[1], p[2] - 3, "#3a2a1a", { r = { name = "ac" } })
end
-- quirk: owl-eyed knothole with two glinting eyes
local kh = c:ellipse(32, 41, 2, 3)
c:fillMask(kh, "#1a0e12")
c:put(31, 40, "#ffe27a", { r = { name = "eye" } }) c:put(33, 40, "#ffe27a", { r = { name = "eye" } })
G.save(c, NAME)
