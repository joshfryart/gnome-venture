-- worm-tea (lean D3o_14)
-- glass preserving jar of murky amber compost tea: cork stopper, foamy top, rising bubbles, a tiny worm swimming inside, hand-tied tag. Quirk: the worm waves from behind the glass.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function T(c, m, ramp, R, bias) G.tone(c, m, X.light(X.pillow(m, R or 4), { amb = 0.1, wrap = 0.25 }), ramp, CUTS, bias) end
local function ell(c, cx, cy, rx, ry, a)
  local p = {}
  for i = 0, 15 do local t = i / 16 * 2 * pi
    local x, y = rx * cos(t), ry * sin(t)
    p[#p + 1] = { cx + x * cos(a) - y * sin(a), cy + x * sin(a) + y * cos(a) } end
  return c:poly(p)
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "worm-tea" }
local GLASS = { "#4a5e74", "#6e88a0", "#98b4c8", "#c4dae8", "#e8f4fa", "#f2fbff" }
local TEA = { "#2e1a10", "#4c2c16", "#744420", "#9c6830", "#c8923e", "#e8bc64" }
local CORK = { "#6a4a30", "#8e6a44", "#b08a5c", "#d0aa78" }
local PINK = { "#a8485e", "#cc6a78", "#f4b4ae" }
c:groundShadow(32, 56, 17, 3)
local body = c:rrect(16, 24, 48, 55, 6)
-- glass back
G.tone(c, body, X.light(X.pillow(body, 8), { amb = 0.3, wrap = 0.4 }), GLASS, CUTS)
-- neck
local neck = c:rect(21, 17, 43, 24)
G.tone(c, neck, X.light(X.pillow(neck, 4), { amb = 0.3, wrap = 0.4 }), GLASS, CUTS)
-- liquid
local liq = c:rrect(18, 30, 46, 53, 5)
local bias = {}
liq:each(function(x, y) if y > 49 then bias[K(x, y)] = -1 end end)
G.tone(c, liq, X.light(X.pillow(liq, 9), { amb = 0.12, wrap = 0.25 }), TEA, CUTS, bias)
-- foam
c:fillMask(c:rect(19, 30, 45, 31), TEA[6])
for x = 19, 45, 3 do c:px(x, 29, TEA[6]) c:px(x + 1, 29, TEA[5]) end
c:px(25, 28, TEA[6]) c:px(36, 28, TEA[6])
-- bubbles
for _, p in ipairs{ {24,36},{37,41},{29,46},{40,35},{22,47} } do c:px(p[1], p[2], TEA[6]) c:px(p[1] + 1, p[2] + 1, TEA[3]) end
-- worm inside
G.line(c, { {27,40},{30,38},{33,41},{36,39},{38,41} }, PINK[2])
G.line(c, { {27,41},{30,39},{33,42},{36,40} }, PINK[1])
c:px(38, 40, PINK[3]) c:px(39, 39, PINK[3]) c:px(39, 38, PINK[2]) c:px(40, 37, PINK[2])
-- glass highlights
G.line(c, { {19,28},{19,45} }, GLASS[6]) G.line(c, { {20,27},{20,31} }, GLASS[5])
G.line(c, { {45,32},{45,50} }, GLASS[3]) c:px(21, 53, GLASS[6])
-- rim
c:fillMask(c:rect(20, 22, 44, 23), GLASS[4]) c:fillMask(c:rect(20, 23, 44, 23), GLASS[2])
-- cork
local ck = c:rrect(21, 10, 43, 17, 2)
T(c, ck, CORK, 3)
for _, p in ipairs{ {25,12},{32,14},{38,12},{29,11} } do c:px(p[1], p[2], CORK[1]) end
-- tag on string around neck
G.line(c, { {22,19},{32,21},{42,19} }, "#e8dcc0")
G.line(c, { {42,19},{46,22},{48,26} }, "#e8dcc0")
local tag = c:rect(46, 26, 52, 32)
c:fillMask(tag, "#f0e4c8") c:fillMask(c:rect(46, 32, 52, 32), "#c0b090") c:fillMask(c:rect(52, 26, 52, 32), "#c0b090")
c:px(49, 28, TEA[3]) c:px(49, 29, TEA[3]) c:px(48, 30, TEA[3]) c:px(50, 30, TEA[3])
G.fin(c, "worm-tea")
