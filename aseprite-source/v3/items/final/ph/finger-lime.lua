-- finger-lime (lean W2_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function T(c, m, R, ramp, amb) local n = X.pillow(m, R) local v = X.light(n, {amb = amb or 0.1, wrap = 0.25}) X.tone(c, m, v, ramp, {cuts = {.22,.4,.56,.72,.86}}) return n, v end
local NAME = "finger-lime"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local SKIN = { "#2a3d2a", "#3e5a35", "#5c7e3f", "#7fa04a", "#a6bf62", "#d3e08e" }
local PINK = { "#8a2f56", "#b84a73", "#df6f94", "#f093ac", "#fbbccb", "#fff0f0" }
local RIND = { "#5a3b2a", "#7a5a2f", "#a5873f", "#cfc06a" }
c:groundShadow(32, 52, 18, 3)
-- slim sausage along a bezier arc, slightly bent, lower-left to upper-right
local m, nrm = G.tube({{12,44},{22,48},{40,34},{50,16}}, function(t) return 4.6 - 1.6 * (1 - t) * (1 - t) - 0.9 * t * t end)
local n, v = T(c, m, 4, SKIN)
-- pores/warts
m:shrink(1):each(function(x, y) if X.hash(x, y, 5) > 0.9 then c:px(x, y, SKIN[v[K(x, y)] > 0.5 and 5 or 1]) end end)
-- dark stem nub (lower-left)
c:fillMask(c:ellipse(10, 43, 2, 1.5), RIND[1]) c:px(9, 42, RIND[3]) c:px(7, 42, RIND[1]) c:px(6, 41, RIND[2])
-- cut end (upper-right): pale rind + pink pearls
local cut = c:ellipse(51, 14, 4.2, 5.2)
T(c, cut, 3, { RIND[4], "#dfd48a", "#ecdfa0", "#f4eab4", "#f9f1c8", "#fffbe0" }, 0.4)
for _, p in ipairs{{50,12},{52,12},{49,14},{51,14},{53,15},{50,16},{52,17},{51,10}} do c:px(p[1], p[2], PINK[3]) c:px(p[1], p[2]-0, PINK[3]) end
c:px(50, 12, PINK[5]) c:px(51, 14, PINK[5]) c:px(52, 17, PINK[2])
-- spilled caviar pearls nearby (quirk: one bursting drop)
for _, p in ipairs{{47,25,3},{54,23,2},{56,28,4},{44,30,2},{52,32,3}} do
  c:px(p[1], p[2], PINK[p[3]]) c:px(p[1]+1, p[2], PINK[2]) c:px(p[1], p[2]+1, PINK[1])
end
c:px(47, 25, PINK[6])
-- spec streak on skin
c:px(26, 42, SKIN[6]) c:px(27, 41, SKIN[6]) c:px(28, 40, SKIN[5])
G.save(c, NAME)
