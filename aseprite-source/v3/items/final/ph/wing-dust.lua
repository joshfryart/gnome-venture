-- wing-dust (lean E2_18)
local NAME = "wing-dust"
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

local GL = { "#5a7aa0", "#86aed0", "#b4daec", "#d4f0f6", "#eaf9fb", "#f8fffe" }
c:groundShadow(32, 55, 15, 3)
local body = E(32, 42, 15, 13)
local neck = c:rect(28, 21, 36, 31) local lip = c:rrect(26, 18, 38, 22, 1)
local all = HP.mask() all:add(body) all:add(neck) all:add(lip)
S(all, GL, 8, "glass", 0.25)
-- glitter fill, wing-dust iridescent
local fill = E(32, 43, 12, 10) fill:cut(c:rect(0, 0, 63, 36))
local IR = { "#f2a8d8", "#a8d8f8", "#c8b0f8", "#f8e8a0", "#b0f0d0", "#fffdf4" }
fill:each(function(x, y) local h = X.hash(x, y, 9) c:put(x, y, h > 0.6 and IR[1 + floor(X.hash(x, y, 2) * 5)] or (h > 0.2 and "#c8a0e0" or "#a080c8"), { r = { name = "dust" } }) end)
-- glass rim + spec
for y = 38, 48 do c:put(19, y, "#f8fffe") end c:put(20, 36, "#f8fffe") c:put(20, 37, "#fffdf4")
P(c:rect(29, 22, 30, 28), "#f8fffe", "sp")
-- cork
S(c:rrect(28, 11, 36, 18, 1), { "#4a2a18", "#7a4a28", "#a8703c", "#c8924e", "#e0b068", "#f2d090" }, 3, "cork")
-- quirk: a loose butterfly wing scale floats above
local sm = E(46, 14, 3, 5) S(sm, { "#6840a8", "#8860d0", "#b088f0", "#d8a8f8", "#f0c8ff", "#fffdf4" }, 2, "scale")
L({ {46, 11}, {46, 18} }, 1, "#6840a8", "vein")
c:sparkle(12, 24) c:sparkle(54, 36) c:sparkle(14, 50)
G.save(c, NAME)
