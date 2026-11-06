-- wooden-dibber (lean D3o_14)
-- turned T-handle crossbar, slim tapering shaft with carved depth rings, worn point caked in soil. Quirk: a cord loop through a hole in the handle end.
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wooden-dibber" }
local WOOD = { "#5a3420", "#7e4c2c", "#a46c3c", "#c88e54", "#e4b274", "#f8d89c" }
local SOIL = { "#2c1c16", "#46301f", "#62442a", "#80603c" }
c:groundShadow(36, 59, 8, 2)
-- shaft with slight taper
local s = c:poly{ {30,16},{35,16},{35,40},{34,50},{32,57},{31,57},{30,50},{29,40} }
G.tone(c, s, X.light(X.pillow(s, 3), { amb = 0.1, wrap = 0.3 }), WOOD, CUTS)
-- grain streaks and depth rings
for _, y in ipairs{ 24, 25, 33, 38 } do c:fillMask(c:rect(30, y, 34, y), y % 2 == 0 and WOOD[1] or WOOD[2]) end
for _, p in ipairs{ {31,28},{32,30},{33,44},{32,20},{33,21} } do c:px(p[1], p[2], WOOD[2]) end
-- soil on the tip
for _, p in ipairs{ {30,52},{31,52},{32,52},{30,53},{31,53},{32,53},{31,54},{32,54},{31,55} } do c:px(p[1], p[2], SOIL[(p[1] + p[2]) % 3 + 2]) end
c:px(30, 52, SOIL[1]) c:px(31, 55, SOIL[1]) c:px(33, 51, SOIL[3]) c:px(29, 54, SOIL[2])
-- T crossbar
local b = c:rrect(14, 8, 50, 16, 3)
G.tone(c, b, X.light(X.pillow(b, 4), { amb = 0.1, wrap = 0.3 }), WOOD, CUTS)
for _, x in ipairs{ 20, 25, 38, 44 } do c:px(x, 11, WOOD[2]) c:px(x + 1, 12, WOOD[2]) c:px(x + 2, 11, WOOD[4]) end
-- turned collar under bar
c:fillMask(c:rect(29, 16, 36, 17), WOOD[2]) c:fillMask(c:rect(29, 18, 36, 18), WOOD[5])
-- hole + cord loop at right end
c:px(46, 12, WOOD[1]) c:px(47, 12, WOOD[1])
local C = { "#e8dcc0", "#b8a888", "#7c6c50" }
G.line(c, { {47,13},{49,16},{50,20},{48,23},{45,22},{44,19} }, C[2])
c:px(50, 18, C[1]) c:px(49, 22, C[3])
c:px(18, 10, WOOD[6]) c:px(19, 10, WOOD[6])
G.fin(c, "wooden-dibber")
