-- stage-tuber-2 (lean W2_26)
-- Potato half-buried in a soil heap; first sprout of two leaf pairs and a curled bud. Quirk: a pale grub peeking out.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local LEAF  = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local SOIL  = { "#2e1d24", "#4a2d2c", "#6b4330", "#8c5c3a", "#aa7a4c", "#c79a64" }
local SPOT  = { "#2e1d24", "#4a2d2c", "#6b4330" }
local CUTS  = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local ltok = { r = { name = "leaf" } }
local function blade(c, ax, ay, bx, by, wmax, ramp)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.6, wmax * sin(pi * min(1, t * 0.93 + 0.07)) ^ 0.7)
  end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), ramp or LEAF, CUTS, nil, ltok)
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.2 and t < 0.93 and t > 0.1 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) end
  end)
  return m
end
local function soil(c, cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  local v = X.light(X.pillow(m, ry), { amb = 0.1, wrap = 0.3 })
  G.tone(c, m, v, SOIL, { 0.2, 0.36, 0.52, 0.68, 0.84 })
  m:copy():shrink(1):each(function(x, y) local h = X.hash(x, y, seed)
    if h > 0.9 then c:px(x, y, SOIL[6]) elseif h < 0.08 then c:px(x, y, SOIL[1]) end end)
  return m
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-tuber-2" }
local PO = { "#4b2f2a", "#6e4630", "#93633e", "#b78350", "#d4a468", "#ecc88a" }
c:groundShadow(32, 54, 21, 3)
soil(c, 32, 50, 22, 8, 3)
-- potato body: lumpy
local pm = HP.mask()
pm:add(c:ellipse(30, 45, 14, 8)) pm:add(c:ellipse(40, 46, 8, 6)) pm:add(c:ellipse(22, 47, 6, 5))
pm:cut(c:rect(0, 49, 63, 63))
local pv = X.light(X.pillow(pm, 7), { amb = 0.08, wrap = 0.25 })
G.tone(c, pm, pv, PO, { 0.2, 0.38, 0.54, 0.7, 0.86 })
-- eyes with brow + pitted dots
for _, e in ipairs{ {24,44},{34,42},{41,46},{29,47} } do c:px(e[1], e[2], PO[1]) c:px(e[1]+1, e[2]-1, PO[6]) c:px(e[1]-1, e[2], PO[2]) end
pm:copy():shrink(1):each(function(x, y) if X.hash(x, y, 8) > 0.93 then c:px(x, y, PO[2]) end end)
c:px(25, 40, "#fff3dc") c:px(26, 40, "#fff3dc") c:px(27, 39, PO[6])
-- soil lip in front
for x = 14, 50 do if X.hash(x, 1, 5) > 0.35 then c:px(x, 49, SOIL[4]) c:px(x, 50, SOIL[3]) end end
-- sprout: stem + two leaf pairs + curled bud
local sm, sn = G.tube({ {30, 43}, {30, 38}, {31, 34}, {31, 30} }, function(t) return 1.3 - 0.3 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }, { 0.3, 0.55, 0.8 })
blade(c, 30, 37, 16, 31, 3.4) blade(c, 31, 36, 46, 30, 3.4)
blade(c, 31, 31, 21, 20, 3.0) blade(c, 31, 30, 41, 19, 3.0)
G.line(c, { {31, 30}, {31, 27}, {32, 25}, {34, 25}, {34, 27} }, LEAF[4])
c:px(33, 24, LEAF[6]) c:px(34, 26, LEAF[5])
-- quirk: grub
G.line(c, { {41, 49}, {43, 48}, {45, 49} }, "#f2e6c8") c:px(45, 49, "#8a5a3a") c:px(42, 48, "#fffaf0")
G.fin(c, "stage-tuber-2")
