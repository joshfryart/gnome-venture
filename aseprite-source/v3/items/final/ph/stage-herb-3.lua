-- stage-herb-3 (lean P1b_O11)
local NAME = "stage-herb-3"
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
local LV = { "#2a4a3c", "#46705a", "#6a9876", "#92bc92", "#bcdcb0", "#e0f2cc" }
local PU = { "#2e1a5a", "#4a2e8a", "#6e4cb4", "#9272d4", "#b898ec", "#e0ccff" }
-- grey-green leaf rosette
blade(31, 47, 20, 42, 6, 46, 2.6, "l1", LV)
blade(33, 47, 44, 42, 58, 46, 2.6, "l2", LV)
blade(31, 47, 22, 36, 14, 33, 2.6, "l3", LV)
blade(33, 47, 42, 36, 50, 33, 2.6, "l4", LV)
local SPK = { "#3a6a50", "#5e9470", "#88bc8c" }
local function spike(cx, top, bot, lean, nm)
  stalk({ {cx,48},{cx,42},{cx+lean,36},{cx+lean*1.5,bot} }, 1.0, SPK, nm.."s")
  local y = bot local k = 0
  while y > top do
    local ox = cx + lean * 1.5 + ((k % 2 == 0) and -1 or 1) * 0.5
    ball(c:ellipse(ox - 2, y, 2, 2.2), 3, PU, nm..k) ball(c:ellipse(ox + 2, y, 2, 2.2), 3, PU, nm..k)
    ball(c:ellipse(ox, y - 1, 1.8, 2.2), 3, PU, nm..k)
    y = y - 3 k = k + 1
  end
  ball(c:ellipse(cx + lean * 1.5, top - 1, 1.4, 2), 2.4, PU, nm.."t")
end
spike(24, 14, 34, -2, "s1")
spike(32, 7, 30, 0, "s2")
spike(40, 14, 34, 2, "s3")
spike(28, 22, 38, -1, "s4")
-- quirk: tiny bee on a spike
local b = c:ellipse(49, 22, 2, 1.5)
G.toneN(c, b, X.pillow(b, 2), { "#6a4a08", "#d8a020", "#ffd848" }, { tok = { r = { name = "bee" } }, cuts = {0.4,0.75} })
c:put(48, 22, "#2b1c26", { r = { name = "bee" } }) c:put(50, 22, "#2b1c26", { r = { name = "bee" } })
c:put(48, 20, "#e0f4ff", { r = { name = "bee" } }) c:put(49, 20, "#e0f4ff", { r = { name = "bee" } })
G.save(c, NAME)
