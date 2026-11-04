-- wind-chime (lean W2_39)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wind-chime" }
local sin, pi, abs, floor = math.sin, math.pi, math.abs, math.floor
local WOOD = { "#3a2113", "#5c3519", "#84501f", "#aa6f2c", "#cf9444", "#efbc6a" }
local SIL  = { "#2f4757", "#4a6e80", "#74a0ae", "#a6cdd2", "#d6ecea", "#fbffff" }
local BRS  = { "#5a3410", "#8a5516", "#b9791f", "#e0a032", "#f5c957", "#fff0a0" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local CORD = "#d9c08a"
local tk = { r = { name = "x" } }
-- hanger ring + cord
local ring = c:ellipse(32, 6, 3.2, 3.2) ring:cut(c:ellipse(32, 6, 1.4, 1.4))
c:fillMask(ring, BRS[4]) c:px(30, 4, BRS[6]) c:px(34, 8, BRS[2])
for y = 9, 12 do c:px(32, y, CORD) end
-- wooden disc
local d = c:rrect(16, 13, 48, 17, 2)
local n = X.pillow(d, 3)
G.toneN(c, d, n, WOOD, { tok = tk })
d:each(function(x, y) if y == 15 and X.hash(x, y, 3) > 0.7 then c:px(x, y, WOOD[2]) end end)
for _, x in ipairs{ 20, 26, 38, 44 } do c:px(x, 16, BRS[5]) end
-- tubes
local tubes = { {17, 22, BRS}, {23, 30, SIL}, {37, 27, SIL}, {43, 19, BRS} }
for _, t in ipairs(tubes) do
  local x0, len, R = t[1], t[2], t[3]
  local y0 = 21
  c:px(x0 + 1, 18, CORD) c:px(x0 + 1, 19, CORD) c:px(x0 + 2, 18, CORD) c:px(x0 + 2, 19, CORD) c:px(x0 + 1, 20, R[2]) c:px(x0 + 2, 20, R[2])
  for y = y0, y0 + len - 1 do
    local cols = { R[5], R[4], R[3], R[2] }
    for i = 0, 3 do c:px(x0 + i, y, cols[i + 1]) end
    if y == y0 or y == y0 + 1 then for i = 0, 3 do c:px(x0 + i, y, R[i == 0 and 3 or 1]) end end
    if y == y0 + 5 then for i = 0, 3 do c:px(x0 + i, y, R[i == 0 and 4 or 2]) end end
    if y == y0 + len - 1 then for i = 0, 3 do c:px(x0 + i, y, R[1]) end end
    if y > y0 + 7 and y < y0 + len - 5 and (y - y0) % 6 < 3 then c:px(x0, y, R[6]) end
  end
  c:px(x0 + 3, y0 + len - 2, R[1])
end
-- clapper cord, ball
for y = 17, 38 do c:px(32, y, CORD) end
for y = 18, 36, 4 do c:px(32, y, "#a88a52") end
local b = c:ellipse(32, 40, 3.2, 3.2)
G.toneN(c, b, X.pillow(b, 3.2), WOOD, { tok = tk })
c:px(31, 38, WOOD[6])
-- sail: little leaf hanging below
local m, nn, T, S = G.blade(32, 44, 37, 50, 31, 57, function(t) return 4.3 * sin(pi * t) ^ 0.8 end)
G.toneN(c, m, nn, LEAF, { tok = tk })
m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.9 then c:px(x, y, LEAF[6]) end end)
c:px(32, 43, CORD)
-- quirk: glint sparkle by the clapper
c:sparkle(41, 45)
G.save(c, "wind-chime")
