-- samphire-salad (lean P1b_O8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "samphire-salad" }
local BOWL = { "#1b3b4a", "#235a68", "#2f8284", "#4aa89a", "#82ccb0", "#c6efd2" }
local SAM  = { "#1c4a2c", "#2a7036", "#42962f", "#6cb83a", "#a0d85a", "#d8f08c" }
local TOM  = { "#5a0f26", "#9a1b32", "#d02e3a", "#ee5a48", "#ff9468", "#ffd0b0" }
local LEM  = { "#9a5a12", "#d08c1a", "#f2b92a", "#ffd848", "#fff08a", "#fffbd0" }
local SAND = { "#4a3550", "#6e5070", "#94708a", "#bf9aa0", "#e0c4b4" }
c:groundShadow(32, 55, 22, 3)
-- samphire stalks: segmented succulent sprigs
local function sprig(pts, w0)
  local m, n, T = G.tube(pts, function(t) return w0 * (1 - 0.45 * t) end)
  G.toneN(c, m, n, SAM, { amb = 0.1, wrap = 0.25, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
  m:each(function(x, y)
    local t = T[K(x, y)]
    if floor(t * 9) % 2 == 1 and t > 0.1 then c:px(x, y, SAM[2]) end
  end)
  local tx, ty = G.bez(pts, 1)
  c:px(floor(tx + 0.5), floor(ty + 0.5), SAM[6])
  return m
end
sprig({ {26,38}, {20,28}, {18,18}, {19,6} }, 2.6)
sprig({ {30,38}, {30,28}, {34,18}, {32,5} }, 2.8)
sprig({ {35,38}, {40,28}, {46,20}, {50,10} }, 2.6)
sprig({ {38,40}, {46,34}, {54,30}, {58,24} }, 2.2)
sprig({ {23,40}, {16,34}, {10,30}, {7,22} }, 2.2)
-- branchlets
sprig({ {19,22}, {15,20}, {13,16}, {12,12} }, 1.6)
sprig({ {45,22}, {42,18}, {41,14}, {43,9} }, 1.6)
-- bowl (half sphere)
local bowl = HP.mask()
for y = 38, 55 do
  local t = (y - 38) / 17
  local hw = 23 * sqrt(max(0, 1 - (t * 0.93) ^ 2)) + 0.5
  for x = floor(32 - hw + 0.5), floor(32 + hw - 0.5) do bowl:set(x, y) end
end
local bn = X.pillow(bowl, 18)
G.toneN(c, bowl, bn, BOWL, { amb = 0.08, wrap = 0.2 })
-- band stripe + foot
for x = 10, 54 do if bowl:has(x, 45) then c:px(x, 45, SAND[5]) end if bowl:has(x, 46) then c:px(x, 46, SAND[3]) end end
c:fillMask(c:rect(23, 55, 41, 56), BOWL[1])
-- rim
local rim = HP.mask() rim:add(c:ellipse(32, 38.5, 23.5, 3.6))
G.toneN(c, rim, X.pillow(rim, 5), BOWL, { amb = 0.3, wrap = 0.3 })
local inn = HP.mask() inn:add(c:ellipse(32, 39, 21, 2.2))
c:fillMask(inn, BOWL[1])
-- cherry tomato (front-left) with bite? no: sits in the bowl
local tm, tn = G.oval(24, 40, 6.5, 6, 0, 1)
G.toneN(c, tm, tn, TOM, { amb = 0.08, wrap = 0.25 })
c:px(21, 37, TOM[6]) c:px(22, 37, TOM[6]) c:px(21, 38, TOM[5])
c:fillMask(c:rect(23, 33, 25, 33), SAM[3]) c:px(22, 34, SAM[2]) c:px(26, 34, SAM[2]) c:px(24, 34, SAM[4]) c:px(24, 33, SAM[5])
-- lemon wedge (quirk: perched on the rim, with a seed)
local w = HP.mask()
w:add(c:poly{ {37,39}, {43,33}, {51,34}, {55,40}, {53,43}, {45,44} })
local wn = X.pillow(w, 5)
G.toneN(c, w, wn, LEM, { amb = 0.15, wrap = 0.3 })
local flesh = HP.mask() flesh:add(c:poly{ {40,39}, {44,36}, {50,37}, {52,40}, {47,41} })
c:fillMask(flesh, LEM[5])
for _, p in ipairs{ {43,38},{46,37},{49,38},{46,40} } do c:px(p[1], p[2], LEM[4]) end
c:px(45, 39, "#fff6c0") c:px(47, 39, LEM[1]) c:px(48, 39, LEM[1])
G.save(c, "samphire-salad")
