-- stage-grain-1 (lean P1pilot)
local NAME = "stage-grain-1"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = { r = { name = nm } } if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local SOIL = { "#1e1218", "#3a2420", "#5e3a2a", "#86583a", "#ae7e4a" }
local BL = { "#143a2c", "#20603a", "#38884a", "#5cae54", "#8ed068", "#c4ee90" }
c:groundShadow(32, 56, 24, 3)
-- soil mound
local mound = c:ellipse(32, 50, 22, 7):cut(c:rect(0, 0, 63, 44))
local mm = c:ellipse(32, 48, 22, 9):cut(c:rect(0, 50, 63, 63)):add(mound)
local soil = c:ellipse(32, 50, 22, 7)
soil:add(c:ellipse(32, 47, 15, 6))
ball(soil, 9, SOIL, "soil", { amb = 0.1, wrap = 0.2 })
soil:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:put(x, y, SOIL[5], { r = { name = "soil" } }) elseif h < 0.07 then c:put(x, y, SOIL[1], { r = { name = "soil" } }) end end)
-- little pebbles
for _, p in ipairs{ {16,52},{17,52},{48,52},{49,52},{47,53} } do c:put(p[1], p[2], "#b8a898", { r = { name = "pb" } }) end
for _, p in ipairs{ {18,53},{50,53} } do c:put(p[1], p[2], "#6a5a60", { r = { name = "pb" } }) end
-- leftover split grain husk with golden kernel at the base (quirk)
local ker = c:ellipse(40, 48, 3, 2)
G.toneN(c, ker, X.pillow(ker, 2.5), { "#8a5a14", "#c08a22", "#e8b840", "#ffe27a" }, { tok = { r = { name = "ker" } }, cuts = {0.3,0.6,0.85} })
c:put(40, 47, "#fff2b0", { r = { name = "ker" } })
-- tall slim blades fanning from the soil, wheat-seedling, each distinct bend
local function blade(ax, ay, cx, cy, bx, by, w, nm)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t) if t > 0.985 then return -1 end return max(0.5, w * (1 - t) ^ 0.7 + 0.3) end, { fold = 0.5 })
  local tok = { r = { name = nm } }
  G.toneN(c, m, n, BL, { tok = tok, cuts = {0.18,0.34,0.5,0.66,0.82}, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and BL[6] or BL[2], tok) end end)
  return m
end
blade(32, 46, 22, 30, 8, 24, 3.2, "b1")
blade(33, 46, 44, 28, 58, 22, 3.2, "b2")
blade(31, 46, 27, 28, 20, 9, 2.8, "b3")
blade(33, 46, 38, 24, 46, 8, 2.8, "b4")
blade(32, 46, 31, 28, 32, 4, 2.6, "b5")
-- pale seed leaf-sheath at the crown
local sh = c:rect(30, 43, 34, 47)
G.toneN(c, sh, X.pillow(sh, 3), { "#7aa65a", "#a8cc7a", "#d4eca0" }, { tok = { r = { name = "sheath" } }, cuts = {0.4,0.75} })
-- dew drop
c:put(21, 31, "#e8fbff", { r = { name = "dew" } }) c:put(22, 31, "#a8dcea", { r = { name = "dew" } }) c:put(21, 32, "#6aa8c8", { r = { name = "dew" } })
G.save(c, NAME)
