-- yogurt (lean E2_18)
local NAME = "yogurt"
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

local BOWL = { "#1c3a68", "#2c5a98", "#4a82c0", "#76aee0", "#a4d0f0", "#d8f0ff" }
local CR = { "#8a86b0", "#b8b8d8", "#dcdcec", "#f0efe8", "#fbf8ec", "#fffdf4" }
c:groundShadow(32, 55, 21, 3)
local b = E(32, 39, 21, 15) b:cut(c:rect(0, 0, 63, 36))
S(b, BOWL, 9, "bowl")
for x = 14, 50 do c:put(x, 44, "#f4f4ec") c:put(x, 45, "#dcdcec") end
S(c:rrect(23, 52, 41, 55, 1), BOWL, 2, "foot")
local rim = E(32, 36, 21, 5) S(rim, BOWL, 3, "rim")
P(E(32, 36, 18, 3), CR[3], "in")
-- yogurt mound and swirl
local mound = E(32, 31, 16, 9) mound:add(E(32, 24, 9, 5)) mound:add(E(32, 20, 4, 3))
S(mound, CR, 8, "mound")
L({ {20, 33}, {28, 36}, {38, 36}, {45, 32} }, 1, CR[2], "sw") L({ {23, 28}, {31, 30}, {41, 28} }, 1, CR[2], "sw") L({ {27, 24}, {34, 25}, {38, 23} }, 1, CR[2], "sw")
c:put(26, 22, "#fffdf4") c:put(27, 21, "#fffdf4")
-- blueberries
for _, p in ipairs{ {28, 18}, {37, 21}, {33, 14} } do
  S(E(p[1], p[2], 3, 3), { "#14183a", "#26306a", "#3c4c9a", "#5a70c0", "#8aa0e0", "#c8d8ff" }, 2, "bb")
  c:put(p[1], p[2] - 2, "#b8d0f0")
end
-- drip down the bowl (quirk) and spoon
S(E(48, 44, 2, 6), CR, 2, "drip") c:put(48, 52, "#fffdf4")
L({ {45, 30}, {51, 18}, {56, 9} }, 2, "#9aa4b4", "spoon") S(E(57, 9, 3, 4), { "#5a6478", "#8a94a8", "#b4bccc", "#d4dae4", "#eef0f6", "#fffdf4" }, 2, "spb")
G.save(c, NAME)
