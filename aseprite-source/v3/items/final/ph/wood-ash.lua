-- wood-ash (lean D3o_14)
-- grey ash mound heaped round two charred log ends, glowing ember specks, drifting ash flecks. Quirk: one ember still lit.
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wood-ash" }
local ASH = { "#4a4658", "#6c677a", "#908ba0", "#b4b0c0", "#d6d3de", "#efedf3" }
local CHAR = { "#1e1618", "#33252a", "#4d3a38", "#6b524a", "#8a6c5c", "#a58a74" }
c:groundShadow(32, 53, 22, 4)
-- charred log ends behind
local l1 = ell(c, 21, 36, 5, 8, 0.5)
local l2 = ell(c, 43, 33, 4.5, 7, -0.6)
T(c, l1, CHAR, 4) T(c, l2, CHAR, 4)
for _, p in ipairs{ {21,36,3,1},{43,33,2.5,1} } do
  c:fillMask(ell(c, p[1], p[2], p[3], p[3] * 1.6, p[1] < 30 and 0.5 or -0.6), CHAR[5])
  c:fillMask(ell(c, p[1], p[2], 1.3, 2, 0), CHAR[3])
end
-- ash mound
local m = c:poly{ {10,52},{13,46},{19,41},{26,36},{32,33},{38,36},{45,40},{51,46},{54,52},{44,55},{32,56},{20,55} }
m:add(c:ellipse(32, 47, 19, 8))
local bias = {}
m:each(function(x, y) local h = X.hash(x, y, 7) if h > 0.86 then bias[K(x, y)] = -1 elseif h < 0.1 then bias[K(x, y)] = 1 end end)
G.tone(c, m, X.light(X.pillow(m, 10), { amb = 0.08, wrap = 0.25 }), ASH, CUTS, bias)
-- ripples from a poke
for _, r in ipairs{ {16,50,24,51},{26,53,38,54},{40,49,49,50} } do G.line(c, { {r[1], r[2]}, {r[3], r[4]} }, ASH[2]) end
-- charred lumps
for _, p in ipairs{ {28,40},{37,44},{20,47} } do c:fillMask(ell(c, p[1], p[2], 2.2, 1.6, 0.3), CHAR[3]) c:px(p[1] - 1, p[2] - 1, CHAR[5]) end
-- embers
local E = { "#8a2a1a", "#d2481e", "#ff8a2a", "#ffd25a" }
for _, p in ipairs{ {24,44},{33,41},{44,47},{30,50} } do c:px(p[1], p[2], E[2]) c:px(p[1] + 1, p[2], E[1]) end
c:px(33, 41, E[4]) c:px(34, 41, E[3]) c:px(33, 40, E[3])
-- drifting flecks
for _, p in ipairs{ {26,28},{38,25},{31,22} } do c:px(p[1], p[2], ASH[4]) end
c:px(26, 27, ASH[6])
c:sparkle(18, 41)
G.fin(c, "wood-ash")
