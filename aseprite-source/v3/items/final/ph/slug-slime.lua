-- slug-slime (lean D2o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, bias, o) local n = X.pillow(m, R) local v = X.light(n, o or { amb = 0.1, wrap = 0.25 }) local k = #ramp - 1 local cuts = {} for i = 1, k do cuts[i] = 0.12 + 0.76 * (i - 1) / max(1, k - 1) end if bias then for k, b in pairs(bias) do bias[k] = floor(b + 0.5) end end G.tone(c, m, v, ramp, cuts, bias) return n, v end
local function tube(c, p, wf, ramp, o) local m, n, T, S = G.tube(p, wf) G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp) return m, n, T, S end
local function disc(c, x, y, r, hex) c:fillMask(c:ellipse(x, y, r, r), hex) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "slug-slime" }
local SL = { "#1f5a3a", "#2f8a43", "#4fb43c", "#86d94a", "#bff26a", "#eaffa8" }
local TR = { "#2a4a3a", "#3c6e46", "#58924c", "#7eb45a" }
local EY = { "#4a3a50", "#7a6a86", "#b6a8c0", "#ece2f2" }
-- slime trail puddle (flat, behind)
local pud = c:ellipse(32, 51, 25, 4)
shade(c, pud, TR, 5)
for x = 12, 52, 5 do c:px(x, 50, TR[4]) end
-- eyestalks
tube(c, { {28,34}, {26,28}, {24,24}, {23,18} }, function(t) return 1.7 - 0.5 * t end, SL)
tube(c, { {36,34}, {37,28}, {38,24}, {40,19} }, function(t) return 1.7 - 0.5 * t end, SL)
for _, e in ipairs{ {23,17}, {40,18} } do
  disc(c, e[1], e[2], 3, EY[3]) disc(c, e[1], e[2] - 1, 2, EY[4]) c:px(e[1] + 1, e[2] + 1, EY[1]) c:px(e[1] + 1, e[2], EY[1])
end
-- glob mound
local g = c:ellipse(32, 43, 19, 8):add(c:ellipse(30, 38, 12, 9)):add(c:ellipse(33, 33, 8, 6))
local bias = {}
X.ao(bias, g, c:ellipse(32, 51, 25, 3), 2, -0.6)
shade(c, g, SL, 8, bias)
-- drip hanging off the right lip, ends in a fat drop
tube(c, { {45,45}, {46,49}, {46,53}, {46,56} }, function(t) return 1.8 - 0.9 * t end, SL)
disc(c, 46, 57, 2, SL[3]) c:px(45, 56, SL[5]) c:px(46, 58, SL[2])
-- bubbles inside
for _, b in ipairs{ {24,43,2}, {38,45,2}, {33,38,1} } do disc(c, b[1], b[2], b[3], SL[5]) c:px(b[1] - 1, b[2] - 1, SL[6]) c:px(b[1] + 1, b[2] + 1, SL[2]) end
-- glossy streak + spec
c:px(25, 35, SL[6]) c:px(26, 34, SL[6]) c:px(27, 33, SL[6]) c:px(25, 36, SL[6]) c:px(27, 32, SL[5])
c:px(41, 41, SL[5]) c:px(42, 42, SL[5])
G.fin(c, "slug-slime")
