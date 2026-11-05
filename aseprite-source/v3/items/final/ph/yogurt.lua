-- yogurt (lean P1b_O19)
local NAME = "yogurt"
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

-- yogurt: glass jar, fruit layer under creamy yogurt with a swirled peak, spoon standing in, one drip down the glass
local CR = { "#8a80aa", "#b8aecc", "#dcd2e0", "#f2e8e4", "#fff6e6", "#fffdf2" }
local FR = { "#3e1038", "#6a1a4e", "#9a2860", "#c43c74", "#e8688c", "#ffa8b0" }
local GL = { "#33467c", "#5578b2", "#86abd6", "#b8d8ea", "#def2f6", "#f6fdff" }
local MT = { "#2e3f66", "#4a6a9a", "#7098bc", "#a0c4da", "#d0e8f0", "#f4ffff" }
-- spoon
tube({ {47, 3}, {44, 10}, {40, 16}, {38, 22} }, 1.3, MT)
local bowl, bn = G.oval(37, 24, 3, 4.2, 0.3, 1)
tone(bowl, bn, MT)
-- jar body
local jar = c:rrect(13, 24, 51, 56, 6)
local cn = {}
jar:each(function(x, y) local nx = max(-0.95, min(0.95, (x - 32) / 20)) cn[K(x, y)] = { G.norm(nx, 0, sqrt(1 - nx * nx)) } end)
-- contents
local fruit = HP.mask() local yog = HP.mask()
jar:each(function(x, y) if y >= 45 + floor(sin(x * 0.45) * 1.0 + 0.5) then fruit:set(x, y) else yog:set(x, y) end end)
tone(yog, cn, CR)
tone(fruit, cn, FR)
fruit:each(function(x, y) if X.hash(x, y, 4) > 0.9 then c:px(x, y, FR[6]) elseif X.hash(x, y, 8) > 0.9 then c:px(x, y, FR[1]) end end)
-- domed top + swirl
local top, tn = G.oval(32, 24, 19, 5, 0, 1)
tone(top, tn, CR)
local sw, sn2 = G.oval(32, 18, 7, 5, 0, 1)
tone(sw, sn2, CR)
local sw2, sn3 = G.oval(32, 13, 4, 3, 0, 1)
tone(sw2, sn3, CR)
c:px(33, 9, CR[4]) c:px(33, 10, CR[3]) c:px(32, 10, CR[4])
for _, p in ipairs{ {28, 18}, {29, 19}, {31, 20}, {35, 18}, {36, 19} } do c:px(p[1], p[2], CR[2]) end
-- glass wall
local ring = jar:copy():cut(jar:copy():shrink(2))
local rn = X.pillow(jar, 6)
tone(ring, rn, GL)
for y = 29, 51 do c:put(18, y, GL[6]) end
c:put(19, 29, GL[5]) c:put(19, 30, GL[5]) c:put(18, 52, GL[5])
-- rim band
c:fillMask(c:rect(15, 25, 49, 25), GL[4])
c:fillMask(c:rect(17, 26, 47, 26), GL[2])
-- drip (quirk)
c:fillMask(c:rect(40, 25, 42, 34), CR[5]) c:fillMask(c:rect(42, 27, 42, 34), CR[3])
local dr, dn = G.oval(41, 36, 2.6, 3.2, pi / 2, 1)
tone(dr, dn, CR)
c:px(40, 34, CR[6])

G.save(c, NAME)
