-- snake-fang (lean P1b_O9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local NAME = "snake-fang"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local IVO = { "#5e4e66", "#8f7c84", "#c3b09c", "#e6d9bd", "#f7efd6", "#fffbea" }
local GUM = { "#4a1a38", "#7a2a50", "#a83e5e", "#d05a6a", "#ea8484", "#f8b4a8" }
local VEN = { "#1f5a2a", "#2f8a34", "#58b43c", "#92d84a", "#c8f06a", "#f0ffa8" }
c:groundShadow(34, 57, 10, 2)
-- fang
local fm, fn, T, S = G.tube({ {22, 14}, {26, 32}, {36, 44}, {46, 50} }, function(t) return max(0.4, 5.6 * (1 - t) ^ 0.8 + 0.3) end)
G.toneN(c, fm, fn, IVO, { amb = 0.1, wrap = 0.2 })
fm:each(function(x, y)
  local k = K(x, y)
  if abs(S[k] - 0.05) < 0.12 and T[k] > 0.18 and T[k] < 0.92 then c:px(x, y, VEN[T[k] > 0.7 and 4 or 2]) end
  if abs(S[k] + 0.55) < 0.1 and T[k] > 0.15 and T[k] < 0.7 then c:px(x, y, IVO[6]) end
end)
-- venom drop at tip (quirk)
local dm, dn = G.oval(47, 54, 2.1, 2.9, 0, 1)
G.toneN(c, dm, dn, VEN, { amb = 0.1 })
c:px(46, 53, VEN[6]) c:px(46, 54, VEN[5])
c:px(46, 51, VEN[3]) c:px(47, 50, VEN[2])
-- gum cap
local gm, gn = G.oval(21, 13, 9.5, 5.2, 0.08, 0.9)
G.toneN(c, gm, gn, GUM, { amb = 0.1, wrap = 0.2 })
-- gum under-lip shading + sheen
c:px(16, 10, GUM[6]) c:px(17, 10, GUM[6]) c:px(18, 9, GUM[5]) c:px(15, 11, GUM[5])
for x = 17, 26 do c:px(x, 18, GUM[2]) end
c:px(22, 19, GUM[1]) c:px(21, 19, GUM[1]) c:px(23, 19, GUM[1])
-- glint
c:px(25, 28, IVO[6]) c:px(25, 29, IVO[6])
G.save(c, NAME)
