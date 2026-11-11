local NAME = "ginseng"
-- ginseng: pale man-shaped taproot (neck wrinkle rings, two legs, two arms, hair rootlets) with a stalk carrying a palmate whorl of 5 toothed leaflets and a red berry cluster. quirk: tiny rootlet curl.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local LEAF  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local SLEAF = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#a8d877" }
local COOL = "#3c6f74"
-- toothed oval leaflet: from base a to tip b (control c), half-width w, side veins at vt (px along)
local function leaflet(ax, ay, cx, cy, bx, by, w, ramp, vts, nm, bias)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.45, w * sin(pi * u ^ 1.2) ^ 0.7)
  end, { fold = 0.5 })
  local tm = HP.mask()
  m:edge():each(function(x, y) if (x + 2 * y) % 3 == 0 and T[K(x, y)] > 0.18 and T[K(x, y)] < 0.97 then tm:set(x, y) end end)
  m:cut(tm)
  local tok = { r = { name = nm } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = 0.12, wrap = 0.22, bias = bias })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tok) return end
    for _, vt in ipairs(vts) do
      local d = t * L - (vt + abs(s) * 3.2)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
  return m
end
local ROOT = { "#6b5238", "#957a58", "#bda27a", "#dcc79d", "#efe0bb", "#fff4d6" }
local BERRY = { "#5a0f1e", "#8e1a2a", "#c62d32", "#ee5a44", "#ff9a78" }
local STEM = { "#2b7046", "#3f8f4c", "#62ad55" }
local rtok = { r = { name = "root" } }
local parts = {
  { {{32,27},{32,34},{31,41},{27,55}}, 3.4, 0.7 },    -- left leg (main body)
  { {{31,38},{33,45},{36,51},{41,57}}, 2.2, 0.6 },    -- right leg
  { {{31,31},{26,33},{21,36},{15,44}}, 1.9, 0.6 },    -- left arm
  { {{33,31},{38,33},{43,36},{49,43}}, 1.9, 0.6 },    -- right arm
}
local body = HP.mask()
-- ground shadow-free hanging root; draw thinner parts first, body last
local order = { 3, 4, 2, 1 }
for _, i in ipairs(order) do
  local p = parts[i]
  local m, n, T = G.tube(p[1], function(t) return p[2] + (p[3] - p[2]) * t end)
  local v = X.light(n, { amb = 0.12, wrap = 0.3 })
  X.tone(c, m, v, ROOT, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = rtok })
  if i == 1 then
    -- neck wrinkle rings: dark broken bands on the upper body
    m:each(function(x, y) local k = K(x, y)
      if T[k] < 0.5 and y % 3 == 0 and X.hash(x, y, 7) > 0.18 then c:put(x, y, v[k] > 0.55 and ROOT[3] or ROOT[2], rtok) end end)
  end
  body:add(m)
end
-- hairy rootlets
for _, p in ipairs{ {26,56},{25,57},{28,56},{41,58},{42,59},{40,58},{14,45},{14,46},{50,44},{51,45},{20,38},{44,38} } do c:put(p[1], p[2], ROOT[2], rtok) end
c:put(24, 58, ROOT[3], rtok) c:put(23, 59, ROOT[2], rtok) c:put(22, 59, ROOT[3], rtok)   -- quirk: rootlet curl
-- stalk
local sm, sn, ST = G.tube({ {32,28}, {32,22}, {33,16}, {32,12} }, function(t) return 1.0 - 0.15 * t end)
local sv = X.light(sn, { amb = 0.15, wrap = 0.3 })
sm:each(function(x, y) local k = K(x, y) c:put(x, y, sv[k] > 0.55 and STEM[3] or STEM[2], { r = { name = "stalk" } }) end)
c:put(32, 28, ROOT[1], rtok) c:put(31, 28, ROOT[1], rtok)
-- whorl of 5 leaflets from the stalk top
leaflet(32,13, 25,12, 15,16, 3.3, LEAF, {4, 8}, "l1")
leaflet(32,13, 39,12, 49,16, 3.3, LEAF, {4, 8}, "l2")
leaflet(32,12, 25,8, 18,5, 2.8, LEAF, {3, 6}, "l3")
leaflet(32,12, 39,8, 46,5, 2.8, LEAF, {3, 6}, "l4")
leaflet(32,12, 31,8, 31,3, 2.4, LEAF, {3, 6}, "l5")
-- berry cluster
for i, b in ipairs{ {30,12}, {34,12}, {32,9}, {32,13} } do
  local bm, bn = G.oval(b[1], b[2], 1.9, 1.9, 0, 1)
  local bt = { r = { name = "berry" .. i } }
  X.tone(c, bm, X.light(bn, { amb = 0.08, wrap = 0.2 }), { BERRY[1], BERRY[2], BERRY[3], BERRY[4], BERRY[5], BERRY[5] }, { cuts = CUTS, tok = bt })
end
c:put(31, 11, "#ffd8c0", { r = { name = "berry1" } })
G.save(c, NAME)
