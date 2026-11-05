-- stage-grain-3 (lean P1b_O11)
local NAME = "stage-grain-3"
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
local SG = { "#1c4a30", "#2e7040", "#4a9650", "#72b85c", "#a0d878", "#d0f4a0" }
-- green wheat ears on stalks
local function ear(cx, top, bot, nm)
  stalk({ {cx,48},{cx,40},{cx+((cx>32) and 1 or -1),32},{cx,bot} }, 1.4, SG, nm.."s")
  local y = bot
  local k = 0
  while y > top do
    local ml = c:ellipse(cx - 1, y, 1.6, 2.2) local mr = c:ellipse(cx + 1, y - 1, 1.6, 2.2)
    ball(ml, 2.5, SG, nm..k) ball(mr, 2.5, SG, nm..k)
    y = y - 3 k = k + 1
  end
  -- awns
  for i = 0, 2 do c:put(cx - 1 + i, top - 1 - (i % 2), SG[5], { r = { name = nm.."a" } }) end
  c:put(cx - 2, top - 3, SG[4], { r = { name = nm.."a" } }) c:put(cx, top - 4, SG[5], { r = { name = nm.."a" } }) c:put(cx + 2, top - 3, SG[4], { r = { name = nm.."a" } })
  c:put(cx, top - 5, SG[6], { r = { name = nm.."a" } })
end
blade(31, 47, 20, 36, 8, 34, 3.4, "f1")
blade(34, 47, 46, 34, 57, 36, 3.4, "f2")
blade(32, 47, 24, 42, 16, 44, 2.6, "f3")
ear(21, 14, 30, "e1")
ear(32, 8, 27, "e2")
ear(43, 14, 30, "e3")
-- quirk: ladybird on the flag leaf
local lb = c:ellipse(14, 34, 2, 1.5)
G.toneN(c, lb, X.pillow(lb, 2), { "#701018", "#b82028", "#e84840" }, { tok = { r = { name = "lady" } }, cuts = {0.4,0.75} })
c:put(14, 33, "#2b1c26", { r = { name = "lady" } }) c:put(13, 35, "#2b1c26", { r = { name = "lady" } })
G.save(c, NAME)
