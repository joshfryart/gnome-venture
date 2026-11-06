-- wind-harp (lean E2_18)
local NAME = "wind-harp"
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

local WOOD = { "#4a2a20", "#6e4228", "#94603a", "#bc8a50", "#dcb070", "#f2d498" }
local pts = { {11, 46}, {11, 36}, {18, 24}, {30, 15}, {47, 11} }
local function armY(x) for i = 1, #pts - 1 do local a, b = pts[i], pts[i + 1] if x >= a[1] and x <= b[1] then return a[2] + (b[2] - a[2]) * (x - a[1]) / (b[1] - a[1]) end end return 11 end
c:groundShadow(32, 56, 22, 3)
-- strings first (under the frame edges)
for x = 17, 43, 4 do
  local y0 = floor(armY(x) + 3)
  L({ {x, y0}, {x, 45} }, 1, "#fff2c0", "str") c:put(x, y0 + 5, "#ffe070") c:put(x, 44, "#c8a050")
end
S(c:line(pts, 4), WOOD, 3, "arm")
S(c:rrect(45, 9, 51, 47, 2), WOOD, 3, "pillar")
S(c:rrect(8, 45, 54, 54, 2), WOOD, 4, "base")
P(c:rect(24, 49, 38, 51), "#2b1c26", "hole") P(c:rect(24, 52, 38, 52), "#94603a", "lip")
for _, p in ipairs{ {46, 20}, {46, 30}, {46, 40} } do c:put(p[1] + 1, p[2], "#f2d498") end
-- breeze swirl (quirk)
L({ {53, 24}, {57, 22}, {58, 27}, {54, 29} }, 1, "#a8e8f0", "wind") c:put(53, 24, "#fffdf4")
c:sparkle(7, 20)
G.save(c, NAME)
