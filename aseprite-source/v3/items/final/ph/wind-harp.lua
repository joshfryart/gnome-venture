-- wind-harp (lean P1b_O19)
local NAME = "wind-harp"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local function tone(m, n, ramp, o) return G.toneN(c, m, n, ramp, o) end
local function ball(cx, cy, rx, ry, ang, ramp, o) local m, n = G.oval(cx, cy, rx, ry, ang, o and o.flat) tone(m, n, ramp, o) return m, n end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, vein)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) return w * sin(pi * min(1, t)) ^ 0.7 + 0.3 end)
  tone(m, n, ramp)
  if vein then m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.17 and T[k] > 0.08 and T[k] < 0.92 then c:put(x, y, vein) end end) end
  return m
end
local function tube(p, w, ramp) local m, n = G.tube(p, function(t) return type(w) == "function" and w(t) or w end) tone(m, n, ramp) return m end
local function cylrect(x0, y0, x1, y1, ramp)
  local m, n = HP.mask(), {}
  local hw, cx = (x1 - x0 + 1) / 2, (x0 + x1) / 2
  for y = y0, y1 do for x = x0, x1 do m:set(x, y) local nx = max(-0.95, min(0.95, (x - cx) / (hw + 0.3))) n[K(x, y)] = { G.norm(nx, 0, sqrt(1 - nx * nx)) } end end
  tone(m, n, ramp) return m
end

-- wind harp (aeolian): slim wooden lyre frame, soundbox with hole, five silver strings, a red ribbon tied to one post
local W = { "#3a1f1c", "#5e3524", "#85502c", "#ad7238", "#d29a50", "#f0c57a" }
local RD = { "#4a0e1e", "#7a1a2a", "#b0302e", "#dc5238", "#f58652", "#ffc088" }
local SIL = "#dceaf4"
local SILD = "#7f94b8"
-- posts first
tube({ {17, 46}, {13, 34}, {16, 22}, {21, 10} }, 2.2, W)
tube({ {47, 46}, {51, 34}, {48, 22}, {43, 10} }, 2.2, W)
-- strings
for _, x in ipairs{ 23, 28, 33, 38, 43 } do
  for y = 13, 43 do c:put(x, y, (y % 7 == 3) and "#ffffff" or SIL) end
  c:put(x, 14, SILD) c:put(x, 15, SILD)
end
-- top bar
local tb = c:rrect(15, 7, 49, 12, 2)
tone(tb, X.pillow(tb, 3), W)
for _, x in ipairs{ 23, 28, 33, 38, 43 } do c:put(x, 9, W[1]) c:put(x, 10, W[6]) end
-- soundbox
local bx = c:rrect(11, 43, 53, 56, 3)
local bn = X.pillow(bx, 5)
tone(bx, bn, W)
local hole = G.oval(32, 50, 6.5, 2.6, 0, 1)
c:fillMask(hole, W[1])
for _, p in ipairs{ {28, 49}, {29, 48}, {30, 48} } do c:px(p[1], p[2], W[2]) end
c:fillMask(c:rect(18, 44, 46, 44), W[1])
for x = 16, 48, 4 do c:put(x, 53, W[2]) c:put(x + 1, 53, W[2]) end
c:put(13, 45, W[6]) c:put(14, 45, W[6]) c:put(13, 46, W[5])
-- ribbon (quirk)
leaf(44, 9, 52, 0, 58, 7, 1.9, RD, RD[5])
tube({ {44, 9}, {47, 14}, {45, 18}, {47, 22} }, 1.0, RD)

G.save(c, NAME)
