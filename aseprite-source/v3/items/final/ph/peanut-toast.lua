-- peanut-toast (lean P1b_O6)
local NAME = "peanut-toast"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function line(pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
local function paint(m, ramp, R, o) o = o or {} local n = X.pillow(m, R) local _, v = G.toneN(c, m, n, ramp, o) return n, v end

local CRUST = { "#3a1c10", "#5e2f18", "#84461e", "#a8602a", "#c97c38", "#e29a52" }
local CRUMB = { "#b9802f", "#d29a46", "#e6b663", "#f3cf86", "#fbe3a6", "#fff2c8" }
local PB    = { "#3e220e", "#6a3c16", "#945a22", "#bc7e34", "#dca050", "#f4cc7c" }
local SHELL = { "#5e4126", "#85603a", "#ae8650", "#cfaa72", "#ead3a0" }
c:groundShadow(30, 52, 18, 2)
local base = c:rrect(9, 19, 47, 50, 4):add(c:ellipse(19, 20, 10, 8)):add(c:ellipse(37, 20, 10, 8))
local bite = c:ellipse(46, 17, 5, 5):add(c:ellipse(42, 13, 4, 3)):add(c:ellipse(48, 23, 3, 3))
base:cut(bite)
local inner = base:copy():shrink(3)
local zone = bite:copy():grow(3)
local crumb = inner:copy():add(base:copy():clip(zone))
local crust = base:copy():cut(crumb)
paint(base, CRUST, 5)
paint(crumb, CRUMB, 9, { amb = 0.2, wrap = 0.4 })
-- recessed shadow just inside the crust (top-left)
crumb:each(function(x, y) if not crumb:has(x - 1, y - 1) or not crumb:has(x, y - 1) then if not zone:has(x, y) then c:px(x, y, CRUMB[1]) end end end)
-- crumb pores
crumb:each(function(x, y) if X.hash(x, y, 3) > 0.93 and not zone:has(x, y) then c:px(x, y, CRUMB[2]) end end)
-- peanut butter spread, lumpy
local pb = c:ellipse(27, 36, 14, 11):add(c:ellipse(22, 29, 9, 7)):add(c:ellipse(34, 41, 10, 7)):add(c:ellipse(18, 40, 6, 6))
pb:clip(inner:copy():shrink(1)):cut(zone:copy():grow(1))
local n, v = paint(pb, PB, 6, { amb = 0.1, wrap = 0.3 })
-- swirls
line(c, { {16,31},{20,28},{26,29},{30,32},{29,36} }, PB[2])
line(c, { {22,41},{27,38},{33,39},{38,43} }, PB[2])
line(c, { {17,34},{21,31},{27,32},{31,36} }, PB[6])
line(c, { {23,44},{29,41},{35,42} }, PB[6])
-- chopped peanut bits
for _, p in ipairs{ {20,35},{30,31},{33,40},{25,43},{15,38} } do
  c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), SHELL[4]) c:px(p[1], p[2], SHELL[5]) c:px(p[1] + 1, p[2] + 1, SHELL[2])
end
c:px(21, 30, "#fff6dc") c:px(22, 30, "#fff6dc")
-- glossy PB drip over the lower edge
c:fillMask(c:rect(14, 46, 15, 49), PB[4]) c:px(14, 46, PB[5]) c:px(15, 49, PB[2]) c:px(14, 50, PB[3])
-- whole peanut in shell (quirk with the bite)
local p1 = c:ellipse(48, 53, 5, 3.6):add(c:ellipse(55, 56, 4.5, 3.2))
paint(p1, SHELL, 3, { amb = 0.2 })
p1:each(function(x, y) if X.hash(x, y, 9) > 0.72 then c:px(x, y, SHELL[2]) end end)
c:px(47, 52, "#fff0cf") c:px(52, 54, SHELL[1]) c:px(52, 55, SHELL[1])
G.save(c, NAME)
