-- white-pelt (lean E2_18)
local NAME = "white-pelt"
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

local WH = { "#6f6a94", "#9a98bd", "#c4c6dc", "#e2e5f0", "#f4f4f6", "#fffdf2" }
c:groundShadow(32, 52, 22, 3)
local m = E(30, 36, 15, 10)
m:add(E(16, 27, 5, 5)) m:add(E(16, 46, 5, 5)) m:add(E(41, 26, 5, 5)) m:add(E(42, 47, 5, 5))
m:add(E(11, 37, 4, 3)) m:add(E(48, 36, 8, 7)) m:add(E(46, 28, 2, 4)) m:add(E(53, 29, 2, 4))
S(m, WH, 7, "pelt")
-- fur strokes
m:each(function(x, y)
  local h = X.hash(x, y, 5)
  if h > 0.86 then c:put(x, y, WH[3]) c:put(x - 1, y + 1, WH[2]) elseif h < 0.07 then c:put(x, y, WH[6]) end
end)
-- face
L({ {46, 34}, {49, 35} }, 1, "#2b1c26") L({ {52, 34}, {54, 34} }, 1, "#2b1c26")
P(E(54, 38, 1, 1), "#e58a98") c:put(52, 40, "#9a5a70")
-- cord with tag (quirk)
L({ {38, 30}, {37, 38}, {38, 44} }, 1, "#a8683c")
P(c:rect(36, 44, 39, 48), "#e0a050") c:put(37, 45, "#7a4020")
c:sparkle(24, 32)
G.save(c, NAME)
