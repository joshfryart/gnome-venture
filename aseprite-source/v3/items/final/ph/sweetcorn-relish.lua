-- sweetcorn-relish (lean D2o_17)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function L(c, pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
local function shade(c, m, ramp, R, tok, bias, o)
  o = o or {} o.tok = tok o.bias = bias
  local n = X.pillow(m, R) local idx, v = G.toneN(c, m, n, ramp, o) return idx, v, n
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sweetcorn-relish" }
local GLASS = { "#5b6f94", "#8aa0bf", "#b4c8d8", "#d4e2e6", "#eaf2ee", "#f8fbf4" }
local COR = { "#8a5a1a", "#b88a22", "#dcae30", "#f2c940", "#ffe068", "#fff2a8" }
c:groundShadow(32, 58, 19, 2)
local glass = c:rrect(12, 28, 51, 56, 7)
shade(c, glass, GLASS, 14, { r = { name = "glass" } })
local inner = c:rrect(14, 31, 49, 54, 6)
local n = X.pillow(inner, 11)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
X.tone(c, inner, v, COR, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.85 }, tok = { r = { name = "relish" } } })
-- kernels, pepper bits, herb flecks
inner:shrink(1):each(function(x, y)
  local h = X.hash(x, y, 13)
  if h > 0.94 then c:px(x, y, "#c93a32") c:px(x + 1, y, "#8e2430")
  elseif h > 0.89 then c:px(x, y, "#4b9650")
  elseif h > 0.7 and x % 2 == y % 2 then c:px(x, y, (v[K(x, y)] or 0.5) > 0.5 and COR[6] or COR[4]) end
end)
for y = 34, 50 do c:px(15, y, GLASS[6]) end
-- gingham cloth cap
local cap = HP.mask()
for y = 15, 28 do
  local t = (y - 15) / 13
  local hw = 11 + 10 * t + (y % 3 == 0 and 1 or 0)
  for x = floor(32 - hw), floor(32 + hw) do cap:set(x, y) end
end
-- pinked scalloped top
for x = 20, 44 do if x % 4 < 2 then cap:cut(c:rect(x, 15, x, 16)) end end
local cn = X.pillow(cap, 8)
local cv = X.light(cn, { amb = 0.15, wrap = 0.3 })
cap:each(function(x, y)
  local chk = ((x // 3) + (y // 3)) % 2
  local l = cv[K(x, y)] or 0.5
  local col
  if chk == 0 then col = (l > 0.62) and "#fff2ea" or ((l > 0.35) and "#f0cfc8" or "#c49a9c")
  else col = (l > 0.62) and "#e8564a" or ((l > 0.35) and "#c43a3e" or "#8e2a3a") end
  c:px(x, y, col)
end)
-- twine
for x = 19, 45 do c:px(x, 29, (x % 2 == 0) and "#c9a064" or "#8e6a3c") c:px(x, 28, "#e6c98a") end
c:fillMask(c:rect(19, 30, 45, 30), "#6a4a2c")
-- quirk: loose bow with dangling ends
L(c, { {30, 29}, {27, 32}, {26, 36} }, "#c9a064")
L(c, { {34, 29}, {37, 32}, {38, 37} }, "#c9a064")
c:px(32, 29, "#8e6a3c") c:px(31, 29, "#e6c98a") c:px(33, 29, "#e6c98a")
-- corncob tag
local tag = c:rrect(36, 41, 47, 51, 1)
shade(c, tag, { "#8a6a4a", "#b99468", "#dcc392", "#f0e0b4", "#f8eecb", "#fffbe6" }, 5, { r = { name = "tag" } })
c:fillMask(c:ellipse(42, 46, 1.6, 3.4), "#f2c940")
for y = 44, 48, 2 do c:px(41, y, "#fff2a8") c:px(43, y + 1, "#dcae30") end
c:px(40, 49, "#4b9650") c:px(41, 49, "#4b9650") c:px(44, 49, "#32764b") c:px(43, 50, "#4b9650")
c:px(36, 42, "#6a4a2c")
c:px(18, 39, "#fff6f2") c:px(18, 40, "#fff6f2")
G.save(c, "sweetcorn-relish")
