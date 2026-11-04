-- tamarind-drink (lean D2o_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "tamarind-drink"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias)
  return n, v
end
local function tub(pts, wfn, ramp, o) o = o or {}
  local m, n, T, S = G.tube(pts, wfn)
  G.tone(c, m, X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.3 }), ramp, o.cuts)
  return m, T, S
end
local DR = { "#2a110a", "#4a2012", "#74371a", "#a05424", "#c97b36", "#e8a95a" }
local ICE = { "#7fa6bf", "#a9cfe0", "#d4eef6", "#f4fcff" }
local BR = { "#3a2216", "#5c3a22", "#7f5530", "#a47845", "#c89d62" }
c:groundShadow(32, 56, 14, 2)
-- glass tumbler (slightly tapered)
local gl = c:poly{ {19, 23}, {45, 23}, {43, 54}, {41, 56}, {23, 56}, {21, 54} }
local liq = c:poly{ {20, 29}, {44, 29}, {42, 53}, {40, 55}, {24, 55}, {22, 53} }
sh(gl, { "#5a7a96", "#8ab0c4", "#b0d4e0", "#d4eef2", "#eefafa", "#fbfdfd" }, 12)
sh(liq, DR, 14, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- liquid gradient: lighter toward the top
liq:each(function(x, y) if y < 33 and (x + y) % 2 == 0 then c:px(x, y, DR[4]) end end)
c:fillMask(c:rect(21, 29, 43, 29), DR[6])
-- glass rim and highlights
for x = 19, 45 do c:px(x, 23, "#eefafa") end
c:px(19, 23, "#fbfdfd") c:px(20, 23, "#fbfdfd")
for y = 31, 50 do c:px(22, y, "#f0fcfc") end
for y = 34, 40 do c:px(23, y, "#d4eef2") end
c:px(42, 35, "#6a4a8a") c:px(41, 48, "#6a4a8a")
-- ice cubes poking above the surface
local i1 = c:rrect(23, 24, 30, 31, 1)
local i2 = c:rrect(32, 25, 39, 32, 1)
sh(i1, ICE, 4, { amb = 0.4, wrap = 0.5 }) sh(i2, ICE, 4, { amb = 0.4, wrap = 0.5 })
c:px(24, 25, "#fbfdfd") c:px(33, 26, "#fbfdfd")
c:px(27, 28, "#4a1a14") c:px(28, 28, "#6e2c1e")  -- quirk: a seed trapped in the ice
-- red/white striped straw
local m, n, T = G.tube({ {36, 38}, {38, 28}, {41, 18}, {45, 8} }, function(t) return 1.3 end)
local sv = X.light(n, { amb = 0.25, wrap = 0.35 })
m:each(function(x, y)
  local k = K(x, y)
  local red = floor(T[k] * 11) % 2 == 0
  local ramp = red and { "#7a1a2a", "#b02a3c", "#d44a52", "#f08088" } or { "#a8a0b0", "#d0cad4", "#f0ecf2", "#fbfdfd" }
  local idx = sv[k] > 0.8 and 4 or sv[k] > 0.55 and 3 or sv[k] > 0.3 and 2 or 1
  c:put(x, y, ramp[idx])
end)
-- tamarind pod garnish hooked on the rim
local pod, pt = tub({ {13, 25}, {18, 14}, {28, 14}, {32, 24} }, function(t)
  return 0.9 + (2.4 + 0.8 * sin(t * pi * 5)) * min(1, t * 5, (1 - t) * 5) end, BR)
pod:each(function(x, y) local t = pt[K(x, y)]
  for i = 1, 3 do if abs(t - i / 4) < 0.012 then c:px(x, y, BR[1]) end end end)
c:px(16, 18, BR[5]) c:px(17, 17, BR[5])
-- condensation drops
c:px(40, 42, "#d4eef2") c:px(40, 43, "#a9cfe0") c:px(25, 45, "#d4eef2")
G.fin(c, NAME)
