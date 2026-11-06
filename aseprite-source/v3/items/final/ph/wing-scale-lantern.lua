-- wing-scale-lantern (lean E2_18)
local NAME = "wing-scale-lantern"
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

local GLOW = { "#a83a30", "#d4543a", "#f27a3c", "#ffa850", "#ffd070", "#fff0a8" }
local GOLD = { "#5a3a10", "#8a5c18", "#b8842c", "#dcb048", "#f2d070", "#fff0a0" }
local function mir(pts) local o = {} for _, p in ipairs(pts) do o[#o + 1] = { 63 - p[1], p[2] } end return o end
local function both(pts) local m = c:poly(pts) m:add(c:poly(mir(pts))) return m end
local ring = E(32, 6, 3, 3) ring:cut(E(32, 6, 1, 1)) S(ring, GOLD, 1.5, "ring")
S(c:rrect(25, 10, 38, 13, 1), GOLD, 2, "cap")
local up = both({ {31, 14}, {44, 13}, {55, 19}, {55, 28}, {46, 33}, {31, 32} })
local lo = both({ {31, 31}, {46, 32}, {51, 39}, {44, 46}, {31, 43} })
local wing = HP.mask() wing:add(up) wing:add(lo)
S(wing, GLOW, 12, "paper", 0.3)
-- vein ribs of the wing, scale spots (the wing is made of scales)
for _, v in ipairs{ { {32, 31}, {45, 15} }, { {32, 31}, {53, 22} }, { {32, 31}, {48, 33} }, { {32, 33}, {47, 41} } } do
  L(v, 1, "#a83a30", "rib") L(mir(v), 1, "#a83a30", "rib")
end
for _, p in ipairs{ {49, 21}, {44, 27}, {45, 38} } do P(E(p[1], p[2], 2, 2), "#fff0a8", "eye") P(E(63 - p[1], p[2], 2, 2), "#fff0a8", "eye") c:put(p[1], p[2], "#d4543a") c:put(63 - p[1], p[2], "#d4543a") end
S(c:rect(30, 13, 33, 44), GOLD, 1.5, "body")
-- tassel + quirk: dangling drop of dust
L({ {32, 44}, {32, 50} }, 1, "#b8842c", "tas")
S(E(32, 53, 3, 4), { "#5a2a70", "#8a48b0", "#b878d8", "#d8a0f0", "#f0c8ff", "#fffdf4" }, 2, "drop")
G.save(c, NAME)
