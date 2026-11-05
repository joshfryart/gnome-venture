-- ember-spark (lean P1b_O0)
-- quirk: a loose spark drifts off with a four-point glint. Charred coal lump with glowing cracks, big licking flame on top.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "ember-spark" }
local floor, abs = math.floor, math.abs
local COAL = { "#17111c", "#271d2b", "#3d303f", "#58465a", "#7a6578", "#a28fa0" }
local FL = { "#b02218", "#e2461a", "#fb8a22", "#ffc43a", "#ffe98c", "#fffbe0" }
local GLOW = { "#c8321a", "#f1661c", "#ffa233", "#ffd866" }

-- coal lump
local pts = { {15,47}, {18,38}, {26,34}, {38,33}, {47,38}, {51,47}, {47,55}, {34,58}, {21,56} }
local coal = c:poly(pts)
local cm, cn = G.oval(33, 46, 19, 12, 0, 0.9)
local lump = coal:copy()
local cnn = X.pillow(lump, 11)
local bias = {}
lump:each(function(x, y) local k = K(x, y)
  if X.hash(floor(x / 2), floor(y / 2), 3) > 0.7 then bias[k] = (X.hash(x, y, 9) > 0.5) and -1 or 1 end end)
G.toneN(c, lump, cnn, COAL, { bias = bias, amb = 0.05, wrap = 0.2, tok = { r = { name = "coal" } } })
-- glowing cracks
local cracks = {
  { {33,36}, {31,41}, {33,45}, {29,49}, {31,54} },
  { {33,45}, {38,47}, {42,45}, {46,49} },
  { {29,49}, {23,48}, {20,44} },
  { {38,47}, {40,52} },
}
for _, l in ipairs(cracks) do
  local mk = c:line(l, 1)
  mk:each(function(x, y) if lump:has(x, y) then c:px(x, y, GLOW[3]) end end)
  mk:each(function(x, y) if lump:has(x, y) and (x + y) % 3 == 0 then c:px(x, y, GLOW[4]) end end)
  c:line(l, 1):grow(1):each(function(x, y) if lump:has(x, y) and not mk:has(x, y) and X.hash(x, y, 4) > 0.45 then c:px(x, y, GLOW[1]) end end)
end
-- facet highlights
c:px(22, 40, COAL[6]) c:px(23, 40, COAL[5]) c:px(21, 41, COAL[5]) c:px(40, 37, COAL[5])

-- flame (leans right, curl tip)
local outer = c:poly{ {30,4}, {33,10}, {38,16}, {42,23}, {43,30}, {40,36}, {33,39}, {26,37}, {22,31}, {23,24}, {27,18}, {28,11} }
local tip = c:poly{ {30,4}, {35,2}, {37,6}, {34,9} }
outer:add(tip)
local layers = { outer }
local m1 = outer:copy():shrink(2) local m2 = m1:copy():shrink(2) local m3 = m2:copy():shrink(2)
c:fillMask(outer, FL[2])
c:fillMask(outer:copy():cut(m1), FL[1])
c:fillMask(m1, FL[3])
c:fillMask(m2, FL[4])
c:fillMask(m3, FL[5])
c:fillMask(m3:copy():shrink(1), FL[6])
-- light flicks: left edge brighter
outer:each(function(x, y) if not outer:has(x - 1, y) and y > 14 and y < 34 and (y % 3 ~= 0) then c:px(x, y, FL[3]) end end)
-- side tongues
c:fillMask(c:poly{ {22,26}, {19,20}, {23,22} }, FL[2])
c:fillMask(c:poly{ {42,26}, {47,19}, {44,25} }, FL[2])
c:px(21, 23, FL[3]) c:px(45, 22, FL[3])
-- sparks
local function spark(x, y, col, big)
  c:px(x, y, FL[6]) c:px(x - 1, y, col) c:px(x + 1, y, col) c:px(x, y - 1, col) c:px(x, y + 1, col)
  if big then c:px(x, y - 2, col) c:px(x, y + 2, col) c:px(x - 2, y, col) c:px(x + 2, y, col) end
end
spark(11, 12, FL[3], true)
spark(53, 9, FL[4], false)
c:px(55, 30, FL[4]) c:px(54, 31, FL[2])
c:px(10, 29, FL[3]) c:px(9, 30, FL[2])
G.save(c, "ember-spark")
