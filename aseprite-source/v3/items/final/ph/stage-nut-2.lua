-- stage-nut-2 (lean P1b_O11)
local NAME = "stage-nut-2"
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
-- slim bent trunk with a side branch
stalk({ {32,50},{31,42},{34,34},{33,26} }, 2.2, BARK, "trunk")
stalk({ {33,36},{38,34},{43,30},{46,26} }, 1.4, BARK, "br1")
stalk({ {32,40},{28,37},{24,33},{21,30} }, 1.4, BARK, "br2")
-- three leaf-balls of different size
local function crown(cx, cy, rx, ry, nm)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = ball(m, max(rx, ry) + 1, LF, nm, { amb = 0.08, wrap = 0.2 })
  m:each(function(x, y) local h = X.hash(x, y, 9) if h > 0.88 then c:put(x, y, LF[6], { r = { name = nm } }) elseif h < 0.1 then c:put(x, y, LF[1], { r = { name = nm } }) end end)
end
crown(31, 15, 9, 8, "c1")
crown(46, 22, 7, 6, "c2")
crown(19, 26, 7, 6, "c3")
-- quirk: single acorn dangling under a branch
local ac = c:ellipse(40, 39, 2, 3)
G.toneN(c, ac, X.pillow(ac, 3), { "#6a4018", "#a2682c", "#d49a48", "#f0c880" }, { tok = { r = { name = "acorn" } }, cuts = {0.3,0.6,0.85} })
local cap = c:rect(38, 36, 42, 37) G.toneN(c, cap, X.pillow(cap, 3), { "#3a2a1a", "#5e4228", "#866038" }, { tok = { r = { name = "cap" } }, cuts = {0.4,0.75} })
c:put(40, 35, BARK[3], { r = { name = "cap" } })
c:put(39, 39, "#fff0c8", { r = { name = "acorn" } })
G.save(c, NAME)
