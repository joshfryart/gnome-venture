-- leech-slime (lean P1b_O3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local function dot(c, x, y, h) c:px(x, y, h) end
local c = HP.canvas{ w=64, h=64, scale=1, name="leech-slime" }
local SL = { "#0e3a3a", "#136a58", "#1f9a6a", "#42c87a", "#86ea8e", "#d0ffc0" }
local LE = { "#1a0a16", "#3a1426", "#5e2038", "#8a3248", "#b84e5a" }
c:groundShadow(32, 52, 22, 3)
local sm = HP.mask()
sm:add(c:ellipse(32, 44, 22, 9)):add(c:ellipse(30, 38, 15, 9)):add(c:ellipse(40, 41, 10, 7))
sm:add(c:rect(14, 44, 16, 52)):add(c:rect(48, 45, 50, 49)):add(c:ellipse(15, 52, 2, 2)):add(c:ellipse(49, 50, 2, 2))
sm:add(c:rect(31, 50, 33, 55)):add(c:ellipse(32, 55, 2, 2))
local bias = {}
G.cast(bias, sm, sm, 0, 0, 0)
shade(c, sm, 9, SL, { cuts = {0.2,0.4,0.58,0.75,0.9} })
-- bubbles inside
for _, b in ipairs{ {22,44,2},{38,46,1},{44,42,2},{28,47,1} } do c:fillMask(c:ellipse(b[1], b[2], b[3], b[3]), SL[2]) c:px(b[1] - 1, b[2] - 1, SL[5]) end
-- glossy spec
c:fillMask(c:rect(20, 33, 24, 34), SL[6]) c:px(19, 35, SL[5]) c:px(25, 33, SL[5])
-- leech: S-curve segmented body rising from slime
local lm, ln, T = G.tube({{36,40},{50,36},{42,24},{28,22}}, function(t) return 3.6 * sin(min(1, t * 1.2 + 0.1) * pi * 0.9 + 0.1) ^ 0.5 + 0.4 end)
local idx = G.toneN(c, lm, ln, LE)
lm:each(function(x, y) local t = T[K(x, y)] if t then
  if floor(t * 22) % 2 == 0 then c:px(x, y, LE[2]) end
  if abs(ln[K(x,y)][1] + ln[K(x,y)][2]) < 0.25 then c:px(x, y, "#e08a2a") end end end)
-- sucker head + eyespots
c:fillMask(c:ellipse(28, 22, 3, 3), LE[1]) c:px(27, 21, LE[4]) c:px(26, 23, "#e8c8d0") c:px(28, 20, "#e8c8d0")
c:px(46, 31, LE[5]) c:px(45, 30, LE[5])
-- quirk: tiny drip glob on tail
c:fillMask(c:ellipse(37, 50, 1, 1), SL[4])
G.save(c, "leech-slime")
