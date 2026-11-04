-- stag-beetle-shell (lean W2_21)
-- A whole empty beetle husk seen from above: split elytra with ridges, shield pronotum, curved toothed mandibles, six curled legs; a chewed exit hole (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stag-beetle-shell" }
local sqrt, max, min, floor = math.sqrt, math.max, math.min, math.floor
local SH = { "#2e1a1f", "#5a2a22", "#8a3f26", "#b5602f", "#d98c45", "#f5bf72" }
local tok = { r = { name = "shell" } }
local function shade(m, R) local n = X.pillow(m, R) G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), SH, nil, nil, tok) return n end
c:groundShadow(32, 58, 12, 2)
-- legs (behind)
for _, L in ipairs{ { {23, 33}, {16, 30}, {12, 33}, {10, 40} }, { {22, 41}, {14, 41}, {11, 46}, {12, 52} }, { {24, 48}, {19, 52}, {17, 55}, {20, 57} } } do
  for side = 0, 1 do
    local p = {}
    for i, q in ipairs(L) do p[i] = side == 0 and q or { 63 - q[1], q[2] } end
    local lm, ln = G.tube(p, function(t) return 1.3 - 0.4 * t end)
    G.tone(c, lm, X.light(ln, { amb = 0.1, wrap = 0.3 }), SH, nil, nil, tok)
  end
end
-- mandibles
for side = 0, 1 do
  local P = { {28, 19}, {20, 17}, {18, 9}, {25, 5} }
  if side == 1 then for i, q in ipairs(P) do P[i] = { 63 - q[1], q[2] } end end
  local mm, mn = G.tube(P, function(t) return 1.9 - 1.1 * t end)
  G.tone(c, mm, X.light(mn, { amb = 0.1, wrap = 0.3 }), SH, nil, nil, tok)
  local teeth = { {21, 14}, {21, 11}, {22, 8} }
  for _, q in ipairs(teeth) do local x = side == 0 and q[1] or 63 - q[1] c:px(x, q[2], SH[5]) c:px(x + (side == 0 and 1 or -1), q[2], SH[3]) end
end
-- head
shade(c:ellipse(32, 19, 5, 3), 3)
c:px(30, 18, SH[6]) c:px(34, 18, SH[1])
-- pronotum
local pro = c:ellipse(32, 26, 10, 6)
shade(pro, 6)
for x = 25, 30 do c:px(x, 22, SH[5]) end
c:px(26, 23, SH[6])
-- elytra halves
local whole = c:ellipse(32, 42, 11, 15)
local L = whole:copy():cut(c:rect(32, 0, 63, 63))
local R = whole:copy():cut(c:rect(0, 0, 32, 63))
shade(L, 8) shade(R, 8)
for y = 28, 56 do
  local hw = 11 * sqrt(max(0, 1 - ((y - 42) / 15)^2))
  c:px(32, y, SH[1])
  if y % 4 ~= 0 then
    for _, f in ipairs{ 0.4, 0.75 } do
      c:px(floor(32 - hw * f), y, SH[2]) c:px(floor(33 + hw * f), y, SH[1])
    end
  end
end
-- shine streak on left half
for y = 33, 44 do c:px(floor(32 - 11 * sqrt(max(0, 1 - ((y - 42) / 15)^2)) * 0.2 - 3), y, SH[6]) end
-- chewed exit hole (quirk)
c:fillMask(c:rect(36, 36, 38, 37), SH[1]) c:px(39, 36, SH[1]) c:px(37, 38, SH[1])
c:px(35, 35, SH[5]) c:px(36, 35, SH[5]) c:px(39, 37, SH[2])
G.fin(c, "stag-beetle-shell")
