-- wind-chime (lean P1b_O19)
local NAME = "wind-chime"
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

-- wind chime: wooden hanger disc, four tubes (steel + brass), centre clapper and a carved wooden wind sail
local STEEL = { "#1e2c52", "#34507e", "#5680ae", "#86b0d0", "#bcdcea", "#effcff" }
local BRASS = { "#4a2c14", "#7a4c1c", "#a87428", "#d4a040", "#f2cc66", "#fff0a8" }
local WOOD = { "#3a1f1c", "#5e3524", "#85502c", "#ad7238", "#d29a50", "#f0c57a" }
local STR = "#e8dcc0"
-- hang string + ring
tube({ {32, 10}, {30, 6}, {34, 4}, {32, 3} }, 0.8, BRASS)
-- disc
local d = G.oval(32, 14, 20, 4.5, 0, 1)
local dm, dn = G.oval(32, 14, 20, 4.5, 0, 0.7)
tone(dm, dn, WOOD)
for x = 16, 48, 8 do c:put(x, 14, WOOD[1]) c:put(x + 1, 14, WOOD[1]) end
-- tubes
local function strung(x, ytop) for y = 17, ytop - 1 do c:put(x, y, STR) end end
strung(16, 24) strung(23, 22) strung(41, 22) strung(48, 24)
local t1 = cylrect(14, 24, 18, 46, STEEL)
local t2 = cylrect(21, 22, 25, 53, BRASS)
local t3 = cylrect(39, 22, 43, 50, STEEL)
local t4 = cylrect(46, 24, 50, 41, BRASS)
for _, t in ipairs{ {14, 24, 18, STEEL}, {21, 22, 25, BRASS}, {39, 22, 43, STEEL}, {46, 24, 50, BRASS} } do
  for x = t[1], t[3] do c:put(x, t[2], t[4][1]) c:put(x, t[2] + 1, t[4][2]) end
  c:put(t[1] + 1, t[2] + 4, t[4][6]) c:put(t[1] + 1, t[2] + 5, t[4][6]) c:put(t[1] + 1, t[2] + 6, t[4][5])
end
for _, e in ipairs{ {14, 46, 18, STEEL}, {21, 53, 25, BRASS}, {39, 50, 43, STEEL}, {46, 41, 50, BRASS} } do
  for x = e[1], e[3] do c:put(x, e[2], e[4][1]) end
end
-- centre string, clapper, sail
for y = 18, 33 do c:put(32, y, STR) end
ball(32, 32, 3.2, 3.2, 0, BRASS)
c:px(31, 31, BRASS[6])
for y = 35, 38 do c:put(32, y, STR) end
local sm, sn = HP.mask(), nil
sm = c:poly{ {32, 38}, {38, 46}, {32, 56}, {26, 46} }
local n2 = X.pillow(sm, 5)
tone(sm, n2, WOOD)
-- carved crescent (quirk)
for _, p in ipairs{ {31, 44}, {30, 46}, {30, 48}, {31, 50}, {32, 50}, {31, 47} } do c:px(p[1], p[2], WOOD[1]) end
c:px(33, 45, WOOD[6]) c:px(32, 41, WOOD[6])

G.save(c, NAME)
