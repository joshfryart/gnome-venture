-- sorrel (lean D2o_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sorrel" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias) return v, n end
local function fill(m, hex) c:fillMask(m, hex) end
-- hastate arrowhead leaf on a slim reddish stem, red midrib, one dewdrop
local LEAF = { "#16382f", "#1f5a3b", "#2f7d3f", "#4f9f45", "#7cc152", "#b4dd7c" }
local STEM = { "#5a2438", "#8a3a3f", "#b45a48", "#d9825a" }
local sm, sn = G.tube({ {32,37}, {30,45}, {35,52}, {32,59} }, function(t) return 1.7 - 0.5 * t end)
shade(sm, 2, STEM, { cuts = { 0.3, 0.55, 0.8 } })
local lobeL = HP.mask() lobeL:add(c:poly{ {30,33}, {24,35}, {18,41}, {14,51}, {23,46}, {29,41} })
local lobeR = HP.mask() lobeR:add(c:poly{ {34,33}, {40,35}, {46,41}, {50,51}, {41,46}, {35,41} })
shade(lobeL, 5, LEAF) shade(lobeR, 5, LEAF)
local blade = HP.mask() blade:add(c:poly{ {32,5}, {37,10}, {40,18}, {40,27}, {37,35}, {32,40}, {27,35}, {24,27}, {24,18}, {27,10} })
shade(blade, 9, LEAF)
-- midrib + veins
for y = 8, 38 do c:px(32, y, y < 22 and LEAF[6] or LEAF[5]) end
for i = 0, 5 do local y = 14 + i * 4
  for d = 1, 5 do c:px(32 - d, y + d, LEAF[5]) c:px(32 + d, y + d, LEAF[3]) end end
for d = 0, 7 do c:px(29 - d, 36 + d, LEAF[5]) c:px(35 + d, 36 + d, LEAF[3]) end
for d = 0, 3 do c:px(32, 38 + d, STEM[3]) end
c:px(32, 36, STEM[3]) c:px(32, 37, STEM[2])
-- red blush at the base of the blade
for _, p in ipairs{ {31,34},{33,34},{30,35},{34,35},{31,36},{33,36} } do c:px(p[1], p[2], STEM[3]) end
-- dewdrop quirk
c:px(36, 19, "#c9ecf2") c:px(37, 19, "#8fc4de") c:px(36, 20, "#8fc4de") c:px(37, 20, "#4f86aa") c:px(36, 19, "#ffffe8")
G.fin(c, "sorrel")
