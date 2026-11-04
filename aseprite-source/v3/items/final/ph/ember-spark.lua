-- ember-spark (lean W2_1)
-- A cooling charcoal lump split by glowing cracks, a four-point spark star and loose flecks rising from it.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ember-spark" }
local COAL = { "#1e1620", "#2e2230", "#443540", "#5e4750", "#7d5d5c", "#9b7a6c" }
local lump = c:poly{ {19,41},{21,33},{28,29},{36,30},{44,34},{47,42},{42,50},{31,52},{22,49} }
local n = X.pillow(lump, 10)
local v = X.light(n, { amb = 0.08, wrap = 0.25 })
local bias = {}
lump:each(function(x, y) local k = K(x, y) if X.hash(x, y, 2) > 0.8 then bias[k] = -1 end end)
G.tone(c, lump, v, COAL, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
-- glowing cracks: deep red, orange core, yellow hot spot
local cracks = {
  { {26,34},{28,38},{27,43},{30,47} },
  { {36,32},{35,37},{38,41},{40,46} },
  { {28,38},{33,40},{38,41} },
}
for _, L in ipairs(cracks) do G.line(c, L, "#b32a1c") end
for _, L in ipairs(cracks) do for i = 1, #L do c:px(L[i][1], L[i][2], "#ff8a2a") end end
c:px(28, 38, "#ffd35a") c:px(33, 40, "#ffd35a") c:px(35, 37, "#ffc04a") c:px(38, 41, "#ffe48a")
c:px(30, 34, COAL[6]) c:px(29, 33, COAL[6])
-- spark star above (quirk)
local sx, sy = 36, 17
for d = 1, 6 do local col = d < 3 and "#ffe48a" or (d < 5 and "#ff9a2e" or "#d9501e")
  c:px(sx, sy - d, col) c:px(sx, sy + d, col) end
for d = 1, 4 do local col = d < 3 and "#ffe48a" or "#ff9a2e"
  c:px(sx - d, sy, col) c:px(sx + d, sy, col) end
c:px(sx - 1, sy - 1, "#fff3b8") c:px(sx + 1, sy - 1, "#ffd35a") c:px(sx - 1, sy + 1, "#ffd35a") c:px(sx + 1, sy + 1, "#ff9a2e")
c:px(sx, sy, "#fffbe6")
-- loose flecks
c:px(24, 24, "#ff9a2e") c:px(46, 25, "#ffc04a") c:px(28, 14, "#d9501e") c:px(44, 14, "#ff9a2e") c:px(22, 29, "#d9501e")
G.fin(c, "ember-spark")
