-- yuzu (lean W2_41)
-- Slightly squat bumpy-skinned citrus: 6-tone yellow, pitted oil-gland dimples, button calyx, short twig with a thorn,
-- and a winged (double-lobed) citrus leaf. Quirk: the thorn.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "yuzu" }
local sin, cos, abs, sqrt, floor = math.sin, math.cos, math.abs, math.sqrt, math.floor

local YEL  = { "#8a6a1c", "#b88e1f", "#dcb02a", "#f1cc3c", "#fbe36a", "#fff4a8" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local WOOD = { "#4a3226", "#6e4a30", "#97693f" }
local ltok = { r = { name = "leaf" } }

c:groundShadow(32, 53, 14, 3)

-- twig + thorn
G.line(c, { {32, 22}, {32, 19}, {30, 15}, {27, 12} }, WOOD[2])
c:px(31, 17, WOOD[3]) c:px(32, 20, WOOD[1])
c:px(33, 15, WOOD[1]) c:px(34, 14, WOOD[2]) c:px(35, 14, WOOD[3]) -- thorn pointing right
c:px(34, 15, WOOD[1])

-- winged leaf: terminal blade + broad wing at base
local wing = G.rell(42, 18, 0.9, -0.2, 4.2, 3.4)
local blade = G.rell(48, 14, 0.8, -0.6, 7, 3.4)
local lm = wing:copy():add(blade)
local ln = X.pillow(lm, 3)
G.tone(c, lm, X.light(ln, { amb = 0.15, wrap = 0.3 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, ltok)
G.line(c, { {35, 20}, {41, 18}, {46, 15}, {52, 11} }, LEAF[6])
G.line(c, { {41, 18}, {44, 20} }, LEAF[2])
c:px(43, 15, LEAF[2]) c:px(46, 17, LEAF[2]) c:px(48, 12, LEAF[5]) c:px(50, 14, LEAF[2])

-- fruit
local fm = c:ellipse(32, 37, 16, 14)
local n = X.pillow(fm, 9)
local v = X.light(n, { amb = 0.08, wrap = 0.22 })
local bias = {}
fm:each(function(x, y)
  local h = X.hash(x, y, 7)
  if h > 0.86 then bias[K(x, y)] = -1 end
  -- oil-gland pits on a loose lattice
  if (x * 2 + y * 3) % 7 == 0 and X.hash(x, y, 3) > 0.35 then bias[K(x, y)] = -1 end
end)
X.ao(bias, fm, c:rect(28, 21, 36, 23), 2, -1)
G.tone(c, fm, v, YEL, { 0.17, 0.34, 0.5, 0.66, 0.82 }, bias)
-- bumpy rim highlight dimples
fm:copy():shrink(1):each(function(x, y)
  if v[K(x, y)] > 0.72 and X.hash(x, y, 11) > 0.88 then c:px(x, y, YEL[6]) end
end)
-- spec
c:px(23, 29, "#fffbe8") c:px(24, 29, "#fffbe8") c:px(23, 30, "#fffbe8") c:px(25, 28, YEL[6])
-- warm green tint near top (unripe) and calyx button
c:px(30, 24, LEAF[3]) c:px(34, 24, LEAF[3]) c:px(31, 23, LEAF[4]) c:px(33, 23, LEAF[4])
c:px(31, 25, YEL[1]) c:px(32, 25, YEL[1]) c:px(33, 25, YEL[1])
c:px(32, 24, WOOD[1]) c:px(32, 23, WOOD[2])
G.fin(c, "yuzu")
