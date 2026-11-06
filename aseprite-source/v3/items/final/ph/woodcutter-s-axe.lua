-- woodcutter-s-axe (lean D3o_14)
-- long diagonal hickory haft with grain and a flared knob, steel head with poll, bevelled cutting edge and bright edge streak. Quirk: a leather thong loop at the knob.
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "woodcutter-s-axe" }
local WOOD = { "#4a2a1c", "#6e4228", "#94603a", "#b88450", "#d6a468", "#ecc88a" }
local STEEL = { "#2e3446", "#4c566c", "#707c94", "#98a6ba", "#c4d0de", "#f2f6fa" }
local LEA = { "#3a2218", "#5e3a26", "#865434" }
local ax, ay, bx, by = 13, 56, 41, 21
local len = sqrt((bx - ax)^2 + (by - ay)^2)
local ux, uy = (bx - ax) / len, (by - ay) / len
local px, py = -uy, ux
c:groundShadow(24, 58, 12, 2)
-- haft
local h = c:line({ {ax, ay}, {bx, by} }, 4)
local bias = {}
h:each(function(x, y) local s = (x - ax) * px + (y - ay) * py
  if (floor(s * 1.5) % 3 == 0) and X.hash(x, y, 3) > 0.3 then bias[K(x, y)] = -1 end end)
G.tone(c, h, X.light(X.pillow(h, 3), { amb = 0.1, wrap = 0.3 }), WOOD, CUTS, bias)
-- knob
local kn = ell(c, ax - 0.5, ay + 0.5, 3.5, 3, math.atan(uy, ux))
T(c, kn, WOOD, 3)
-- thong loop
G.line(c, { {17,50},{14,47},{12,48},{13,51},{16,52} }, LEA[2]) c:px(14, 47, LEA[3]) c:px(17, 50, LEA[1])
-- head in local (u along haft, v across)
local function W(u, v) return { bx + ux * u + px * v, by + uy * u + py * v } end
local head = c:poly{ W(-4,-6), W(5,-6), W(6,3), W(10,12), W(1,14), W(-8,12), W(-4,3) }
local hb = {}
head:each(function(x, y) local u = (x - bx) * ux + (y - by) * uy local v = (x - bx) * px + (y - by) * py
  if v > 9 then hb[K(x, y)] = 1 end
  if v < -2 and u > 0 then hb[K(x, y)] = -1 end end)
G.tone(c, head, X.light(X.pillow(head, 7), { amb = 0.1, wrap = 0.2 }), STEEL, CUTS, hb)
-- cutting edge streak + bevel
G.line(c, { W(-8,12), W(1,14), W(10,12) }, STEEL[6])
G.line(c, { W(-7,10.5), W(1,12.3), W(9,10.5) }, STEEL[4])
-- eye of the head, haft passes through
G.line(c, { W(-3,-5), W(4,-5) }, STEEL[3])
local eye = c:line({ W(-1,-6), W(2,-6) }, 1)
c:px(floor(bx + px * -6 + 0.5), floor(by + py * -6 + 0.5), STEEL[1])
-- rivet glint
local g = W(0, 0) c:px(floor(g[1]), floor(g[2]), STEEL[6])
c:sparkle(floor(W(-4,10)[1]), floor(W(-4,10)[2]))
G.fin(c, "woodcutter-s-axe")
