-- sukuma-wiki (lean D2o_16)
local NAME = "sukuma-wiki"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function blob(m, ramp, R, o, cuts, bias)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  G.tone(c, m, v, ramp, cuts, bias)
  return v, n
end
local function lines(pts, hex) G.line(c, pts, hex) end
local function hits(m, fn) m:each(fn) end

-- sukuma wiki: black iron pot of sauteed collard greens with tomato bits; quirk: wooden spoon leaning in the pot
local IRON = { "#191822", "#262636", "#3a3a52", "#53526c", "#74728c", "#a09eb8" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#a3d070" }
local WOOD = { "#4a2c24", "#6e4430", "#946240", "#bc8a58", "#dcb078" }
local TOM = { "#6a1424", "#a82430", "#d83c3a", "#ff7a58" }
c:groundShadow(32, 56, 22, 3)
-- spoon behind
local sp = G.tube({ { 40, 28 }, { 44, 20 }, { 48, 14 }, { 52, 8 } }, function(t) return 1.6 end)
blob(sp, WOOD, 2)
local bowl = G.rell(41, 28, 0.5, 0.85, 4, 2.8)
blob(bowl, WOOD, 2)
-- legs and handles
c:fillMask(c:rect(14, 52, 18, 56), IRON[2]) c:fillMask(c:rect(46, 52, 50, 56), IRON[2]) c:px(14, 52, IRON[4]) c:px(46, 52, IRON[4])
local hl = c:ellipse(9, 40, 4, 4):cut(c:ellipse(9, 40, 2, 2))
blob(hl, IRON, 2)
local hr = c:ellipse(55, 40, 4, 4):cut(c:ellipse(55, 40, 2, 2))
blob(hr, IRON, 2)
-- pot body
local body = c:ellipse(32, 38, 23, 17):cut(c:rect(0, 0, 63, 33))
blob(body, IRON, 12, { amb = 0.06, wrap = 0.2 })
for y = 40, 50 do c:px(15 + (y - 40) // 2, y, IRON[5]) end
c:fillMask(c:rect(18, 50, 46, 50), IRON[1])
-- rim
local rim = c:ellipse(32, 33, 24, 6)
blob(rim, IRON, 3, { amb = 0.3, wrap = 0.3 })
-- greens heap
local mound = c:ellipse(32, 32, 21, 4.5)
c:fillMask(mound, LEAF[1])
local leaves = { { 22, 31, 1, 0.2, 8, 4 }, { 41, 31, 1, -0.3, 8, 4 }, { 30, 28, 1, -0.1, 8, 4.4 }, { 38, 27, 1, 0.3, 7, 4 }, { 26, 26, 1, 0.6, 7, 3.6 }, { 33, 24, 1, 0.1, 8, 4.4 }, { 21, 28, -1, -0.5, 6, 3.4 }, { 43, 28, 1, 0.5, 6, 3.4 } }
for i, L in ipairs(leaves) do
  local ux, uy = cos(L[4]), sin(L[4])
  local m = G.rell(L[1], L[2], ux, uy, L[5], L[6]):cut(c:rect(0, 34, 63, 63))
  local nn = X.pillow(m, 3)
  blob(m, LEAF, 3, { amb = 0.1 + 0.03 * (i % 3), wrap = 0.3 })
  lines({ { L[1] - ux * L[5] * 0.8, L[2] - uy * L[5] * 0.8 }, { L[1] + ux * L[5] * 0.8, L[2] + uy * L[5] * 0.8 } }, LEAF[6])
  lines({ { L[1], L[2] }, { L[1] + ux * 3 - uy * 2, L[2] + uy * 3 + ux * 2 } }, LEAF[2])
end
-- tomato bits and shine
for _, p in ipairs{ { 25, 30 }, { 35, 26 }, { 40, 30 }, { 30, 23 }, { 21, 31 } } do
  c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), TOM[3]) c:px(p[1], p[2], TOM[4]) c:px(p[1] + 1, p[2] + 1, TOM[1])
end
-- steam
lines({ { 24, 18 }, { 26, 15 }, { 24, 12 }, { 26, 9 } }, "#e8e4ee") lines({ { 18, 22 }, { 19, 19 }, { 18, 17 } }, "#c9c4d6")

G.fin(c, NAME)
