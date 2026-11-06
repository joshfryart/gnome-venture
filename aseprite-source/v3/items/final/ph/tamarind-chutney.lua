-- tamarind-chutney (lean D2o_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "tamarind-chutney"
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
local CE = { "#1c3a55", "#2a5878", "#3a7c96", "#5aa0ae", "#88c4c4", "#bfe6dc" }
local CH = { "#2a140c", "#45230f", "#69391a", "#8e5527", "#b87a3a", "#dca362" }
local WD = { "#4a2e1a", "#6e4626", "#946236", "#b88650", "#d8aa70" }
c:groundShadow(30, 55, 19, 2.5)
-- bowl
local rimO = c:ellipse(30, 37, 20, 7)
local bowl = c:ellipse(30, 41, 20, 14):cut(c:rect(0, 0, 63, 36)):add(rimO)
bowl:cut(c:rect(0, 55, 63, 63))
sh(bowl, CE, 13, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
c:fillMask(c:rect(23, 53, 37, 54), CE[1])
-- glaze band + dots on the bowl
for x = 12, 48 do local y0 = floor(37 + 7 * sqrt(max(0, 1 - ((x - 30) / 20) ^ 2)) + 0.5) c:px(x, y0 + 3, CE[5]) c:px(x, y0 + 5, CE[5]) end
for x = 14, 46, 4 do c:px(x, 47 + floor(3 * ((x - 30) / 16) ^ 2), CE[6]) end
-- inner wall + chutney surface
local inner = c:ellipse(30, 37, 17, 5)
sh(inner, { CE[1], CE[1], CE[2], CE[3], CE[3], CE[4] }, 4)
local sur = c:ellipse(30, 38, 16, 4.2)
sh(sur, CH, 5, { amb = 0.3, wrap = 0.5 })
for t = 0, 1, 0.04 do local a = t * 5.2 + 0.5 local r = 1 - t * 0.7
  c:px(floor(30 + cos(a) * 12 * r + 0.5), floor(38 + sin(a) * 2.8 * r + 0.5), CH[6]) end
c:px(24, 36, "#f4d8a0") c:px(25, 36, "#f4d8a0")
-- chutney drip over the front lip
local dp = c:rrect(36, 41, 38, 46, 1)
sh(dp, CH, 2, { amb = 0.4, wrap = 0.4 })
c:px(36, 42, CH[6]) c:px(37, 46, CH[1])
-- wooden spoon leaning out of the bowl
tub({ {34, 36}, {40, 28}, {46, 20}, {53, 12} }, function(t) return 1.6 - 0.3 * t end, WD)
local sp = G.rell(33.5, 37, 0.8, -0.5, 3.8, 2.6)
sh(sp, CH, 3, { amb = 0.3, wrap = 0.4 })
for _, p in ipairs{ {52, 11}, {53, 11} } do c:px(p[1], p[2], WD[5]) end
-- quirk: a tamarind seed floating on top
c:fillMask(G.rell(25, 38.5, 1, 0.2, 2.2, 1.4), "#3a1810") c:px(24, 38, "#c27a58")
G.fin(c, NAME)
