-- tallow-wax (lean D2o_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "tallow-wax"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias)
  return n, v
end
local function tub(pts, wfn, ramp, o) o = o or {}
  local m, n, T, S = G.tube(pts, wfn)
  G.tone(c, m, X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.3 }), ramp, o.cuts)
  return m, T, S
end
local TL = { "#8c7a68", "#b5a38a", "#d6c6a4", "#ede0bc", "#faefd2", "#fffbec" }
local WICK = { "#2a1a14", "#4a3326", "#7a5a40", "#a88460" }
c:groundShadow(32, 54, 18, 2.5)
local top = c:ellipse(32, 33, 16, 6)
local blk = c:rrect(16, 33, 48, 52, 5):add(top)
-- front block
local front = blk:copy():cut(top)
sh(blk, TL, 9, { amb = 0.08, wrap = 0.22, cuts = { 0.25, 0.42, 0.58, 0.74, 0.88 } })
-- top face brighter, with a scooped hollow
sh(top, { TL[3], TL[4], TL[5], TL[5], TL[6], TL[6] }, 6, { amb = 0.5, wrap = 0.5 })
local hol = c:ellipse(35, 33, 6.5, 2.8)
sh(hol, { TL[1], TL[2], TL[3], TL[4], TL[4], TL[5] }, 3, { amb = 0.05, wrap = 0.1 })
c:fillMask(c:ellipse(35, 32.5, 6.5, 0.9), TL[1])
-- rim lip highlight upper-left and soft crease at front edge
for x = 20, 40 do local y = floor(33 + 6 * sqrt(max(0, 1 - ((x - 32) / 16) ^ 2)) + 0.5) c:px(x, y, TL[2]) end
-- scratches / fat grain on the front
for _, p in ipairs{ {22, 42, 5}, {30, 46, 7}, {38, 41, 4}, {26, 49, 4}, {41, 47, 3} } do for i = 0, p[3] - 1 do c:px(p[1] + i, p[2], TL[2]) end end
-- melted drips down the front
for _, d in ipairs{ {21, 45}, {37, 50} } do
  local dm = c:rrect(d[1], 38, d[1] + 2, d[2], 1)
  sh(dm, { TL[3], TL[4], TL[5], TL[5], TL[6], TL[6] }, 2, { amb = 0.4, wrap = 0.4 })
end
c:px(22, 44, TL[6]) c:px(38, 49, TL[6])
-- chipped corner (quirk 1) + wick
c:px(47, 40, TL[2]) c:px(46, 41, TL[1])
tub({ {31, 33}, {31, 27}, {27, 24}, {26, 17} }, function(t) return 1.1 - 0.2 * t end, WICK)
c:px(26, 16, WICK[1]) c:px(27, 16, WICK[1]) c:px(25, 17, "#e86a2a") c:px(26, 15, "#f6b040")
-- drop of wax caught on the hollow lip
c:fillMask(c:ellipse(41, 36, 1.4, 1.8), TL[5]) c:px(40, 35, TL[6])
G.fin(c, NAME)
