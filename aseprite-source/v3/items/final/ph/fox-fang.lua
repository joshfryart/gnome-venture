-- fox-fang (lean W2_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function T(c, m, R, ramp, amb) local n = X.pillow(m, R) local v = X.light(n, {amb = amb or 0.1, wrap = 0.25}) X.tone(c, m, v, ramp, {cuts = {.22,.4,.56,.72,.86}}) return n, v end
local NAME = "fox-fang"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local BONE = { "#8a7a8c", "#b5a8ad", "#d8cdc0", "#eee5d2", "#faf3e2", "#fffaf0" }
local LEATH = { "#3a2220", "#5e3a2c", "#855437", "#a97646", "#cf9c62", "#ecc88e" }
local CORD = { "#4a3a5a", "#6f5a82", "#9a85a8" }
c:groundShadow(32, 54, 12, 2)
-- cord loop up top (twisted)
local loop = G.tube({{27,18},{22,8},{34,5},{33,16}}, function(t) return 1.1 end)
local lm = loop
for _, p in ipairs{} do end
lm:each(function(x, y) c:px(x, y, ((x + y) % 3 == 0) and CORD[3] or CORD[2]) end)
-- fang: curved cone from wide base (upper-left) to sharp tip (lower-right)
local fang, fn = G.tube({{28,20},{30,32},{38,42},{50,50}}, function(t) return 6.2 * (1 - t) ^ 0.85 + 0.4 end)
T(c, fang, 6, BONE)
-- enamel gloss streak + pulp-cavity shade
fang:each(function(x, y) if x < 33 and y > 24 and y < 34 and fang:has(x - 2, y) and not fang:has(x - 3, y) then c:px(x, y, BONE[6]) end end)
c:px(29, 27, BONE[6]) c:px(30, 29, BONE[6]) c:px(47, 49, BONE[1])
-- leather wrap around base with stitches
local wrap = c:rect(22, 19, 35, 27)
wrap:clip(c:rect(22, 19, 35, 27))
T(c, c:rrect(22, 18, 35, 27, 2), 4, LEATH)
for x = 24, 34, 3 do c:px(x, 20, LEATH[6]) c:px(x + 1, 22, LEATH[1]) c:px(x, 24, LEATH[6]) c:px(x + 1, 26, LEATH[1]) end
-- band cuts
for y = 19, 27, 4 do for x = 23, 34 do c:px(x, y, LEATH[1]) end end
-- quirk: tiny chip nick near the tip
c:px(44, 44, 0 == 1 and "#000" or BONE[2])
c:sparkle(18, 36)
G.save(c, NAME)
