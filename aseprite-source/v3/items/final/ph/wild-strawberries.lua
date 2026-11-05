-- wild-strawberries (lean E2_18)
local NAME = "wild-strawberries"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function S(m, ramp, R, nm, amb)
  local n = X.pillow(m, R or 4)
  return X.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, { cuts = { .22, .4, .56, .72, .86 }, tok = { r = { name = nm or "p" } } })
end
local function E(x, y, rx, ry) return c:ellipse(x, y, rx, ry) end
local function P(m, col, nm) m:each(function(x, y) c:put(x, y, col, { r = { name = nm or "d" } }) end) end
local function L(pts, w, col, nm) P(c:line(pts, w), col, nm) end

local RED = { "#4a1424", "#8a1c30", "#c62c3c", "#e8504a", "#f58a66", "#ffc79a" }
local GR  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local WHB = { "#6a8a5a", "#9ab878", "#c8dc98", "#e8efc0", "#f6f6d8", "#ffffee" }
local function stem(pts, w) local m = c:line(pts, w) S(m, { "#2a5a34", "#3a7a40", "#4f9a4c", "#78bd5c" }, 2, "st") end
stem({ {30, 17}, {30, 26} }, 2) stem({ {30, 26}, {26, 30}, {19, 33} }, 2) stem({ {30, 26}, {38, 30}, {44, 34} }, 2) stem({ {30, 26}, {31, 38}, {31, 44} }, 2)
-- trifoliate leaf on the right-up
local function leaf(cx, cy, rx, ry, ang)
  local m, n = G.blade(cx - rx * cos(ang), cy - rx * sin(ang), cx, cy - ry * 0.5, cx + rx * cos(ang), cy + rx * sin(ang), function(t) return max(0.5, ry * sin(pi * t) ^ 0.8) end, { fold = 0.3 })
  G.toneN(c, m, n, GR, { tok = { r = { name = "lf" .. cx } }, amb = 0.1, wrap = 0.2 })
end
stem({ {31, 24}, {40, 20}, {47, 18} }, 1)
leaf(54, 12, 6, 4, -0.2) leaf(52, 22, 6, 4, 0.5) leaf(44, 14, 6, 4, -0.9)
-- berries
local function berry(cx, cy, rx, ry, ramp, seed, calx)
  local m = E(cx, cy, rx, ry) m:cut(c:poly{ {cx - rx - 1, cy + ry + 1}, {cx - rx + 1, cy + ry - 3}, {cx - 2, cy + ry + 1} }) 
  local idx = S(m, ramp, 5, "b" .. cx)
  m:shrink(1):each(function(x, y) if (x + y * 2) % 5 == 0 and X.hash(x, y, 3) > 0.2 then c:put(x, y, seed, { r = { name = "sd" } }) end end)
  P(E(cx, cy - ry + 1, 4, 2), GR[3], "cal") c:put(cx - 3, cy - ry + 1, GR[5]) c:put(cx + 3, cy - ry + 1, GR[2]) c:put(cx, cy - ry - 1, GR[2])
  local bx, by = G.specAt(m, X.pillow(m, 5), 30) if bx then c:put(bx, by, ramp[6]) c:put(bx, by + 1, ramp[5]) end
end
berry(18, 41, 6, 8, RED, "#ffd860")
berry(44, 45, 7, 9, RED, "#ffd860")
berry(31, 53, 4, 5, WHB, "#c8a040")   -- quirk: one unripe white berry
-- flower
for i = 0, 4 do local a = i * 2 * pi / 5 - pi / 2 P(E(30 + cos(a) * 4, 9 + sin(a) * 4, 2.4, 2.4), "#fffbea", "pet") end
P(E(30, 9, 2, 2), "#f2b82c", "ctr") c:put(30, 8, "#fff0a0") c:put(31, 10, "#c8801c")
G.save(c, NAME)
