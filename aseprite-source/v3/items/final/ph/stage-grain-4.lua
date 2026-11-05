-- stage-grain-4 (lean P1b_O11)
local NAME = "stage-grain-4"
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
local ST = { "#7a4c14", "#a8741e", "#d4a02e", "#f0c85a", "#fff0a0" }
local function ear(cx, top, bot, nm, lean)
  stalk({ {cx,48},{cx,40},{cx+lean,32},{cx+lean,bot+2} }, 1.3, ST, nm.."s")
  local y = bot
  local k = 0
  while y > top do
    local ox = cx + lean
    ball(c:ellipse(ox - 1, y, 1.8, 2.3), 2.6, GOLD, nm..k)
    ball(c:ellipse(ox + 1, y - 1, 1.8, 2.3), 2.6, GOLD, nm..k)
    y = y - 3 k = k + 1
  end
  for i = -2, 2 do c:put(cx + lean + i, top - 1 - abs(i), GOLD[5], { r = { name = nm.."a" } }) end
  c:put(cx + lean - 3, top - 2, GOLD[4], { r = { name = nm.."a" } }) c:put(cx + lean + 3, top - 2, GOLD[4], { r = { name = nm.."a" } })
  c:put(cx + lean, top - 4, GOLD[6], { r = { name = nm.."a" } })
end
blade(31, 47, 20, 38, 9, 40, 3, "d1", { "#6a4410", "#9a6a1c", "#c89430", "#e4b848", "#f4d878", "#fff0b0" })
blade(34, 47, 46, 38, 56, 41, 3, "d2", { "#6a4410", "#9a6a1c", "#c89430", "#e4b848", "#f4d878", "#fff0b0" })
ear(20, 16, 33, "e1", -1)
ear(43, 18, 34, "e3", 1)
ear(32, 8, 28, "e2", 0)
-- quirk: heavy ear on a drooping bent stalk, plus fallen grains
stalk({ {33,47},{34,34},{40,24},{46,28} }, 1.3, ST, "bend")
for k = 0, 3 do
  ball(c:ellipse(46 + (k%2)*2 - 1, 29 + k*3, 1.8, 2.3), 2.6, GOLD, "bh"..k)
end
for _, p in ipairs{ {26,52},{28,53},{37,53} } do ball(c:ellipse(p[1], p[2], 1.5, 1), 2, GOLD, "fg") end
G.save(c, NAME)
