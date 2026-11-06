-- smoked-paprika (lean D2o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, bias, o) local n = X.pillow(m, R) local v = X.light(n, o or { amb = 0.1, wrap = 0.25 }) local k = #ramp - 1 local cuts = {} for i = 1, k do cuts[i] = 0.12 + 0.76 * (i - 1) / max(1, k - 1) end if bias then for k, b in pairs(bias) do bias[k] = floor(b + 0.5) end end G.tone(c, m, v, ramp, cuts, bias) return n, v end
local function tube(c, p, wf, ramp, o) local m, n, T, S = G.tube(p, wf) G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp) return m, n, T, S end
local function disc(c, x, y, r, hex) c:fillMask(c:ellipse(x, y, r, r), hex) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "smoked-paprika" }
local BUR = { "#3a2618", "#5e3d24", "#8a5c36", "#b58450", "#d6ab6e", "#f0cf92" }
local TW  = { "#5a3a1e", "#8a6234", "#bd8d4c", "#e6bd72" }
local RED = { "#4a1218", "#7c1a1d", "#b3261e", "#d94a26", "#f27a3a", "#ffb36b" }
local SM  = { "#7a7088", "#a89eb4", "#d2cadc" }
c:groundShadow(32, 56, 22, 3)
-- pouch
local body = c:ellipse(27, 43, 15, 11):add(c:ellipse(27, 34, 10, 8))
local frill = c:poly{ {19,19}, {35,19}, {33,27}, {21,27} }
local bias = {}
X.ao(bias, body, frill, 2, -0.8)
local n, v = shade(c, body:copy():add(frill), BUR, 8, bias)
-- weave
body:copy():add(frill):each(function(x, y) if (x + y) % 2 == 0 and X.hash(x, y, 3) > 0.45 then c:px(x, y, BUR[2]) end end)
-- cinch + twine
c:fillMask(c:rect(21, 27, 33, 28), TW[2]) c:fillMask(c:rect(21, 27, 31, 27), TW[3])
for x = 21, 33 do c:px(x, 29, BUR[1]) end
tube(c, { {27,27}, {24,24}, {20,26}, {19,29} }, function(t) return 1.2 end, TW)
tube(c, { {27,27}, {30,24}, {34,26}, {35,29} }, function(t) return 1.2 end, TW)
disc(c, 27, 27, 2, TW[2]) c:px(26, 26, TW[4])
-- open mouth heaped with powder
local mouth = c:ellipse(27, 19, 8, 3)
shade(c, mouth, RED, 4)
c:px(24, 18, RED[6]) c:px(25, 18, RED[5])
-- spilled heap
local heap = c:ellipse(47, 51, 9, 5)
local hb = {}
X.ao(hb, heap, body, 2, -0.6)
shade(c, heap, RED, 6, hb)
heap:each(function(x, y) if X.hash(x, y, 9) > 0.86 then c:px(x, y, RED[6]) end end)
c:px(45, 48, RED[6]) c:px(44, 49, RED[6])
-- stray grains
c:px(55, 54, RED[3]) c:px(40, 56, RED[2])
-- smoke wisp (quirk: curls into a little spiral)
G.line(c, { {27,16}, {29,13}, {27,10}, {29,7}, {32,7}, {32,10}, {30,10} }, SM[2])
c:px(29, 7, SM[3]) c:px(27, 10, SM[3])
G.fin(c, "smoked-paprika")
