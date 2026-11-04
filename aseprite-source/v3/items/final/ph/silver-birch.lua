-- silver-birch (lean W2_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "silver-birch" }
local floor, abs = math.floor, math.abs
local BARK = { "#6f6783", "#9e98ae", "#c9c6d2", "#e8e6ec", "#f8f6f6", "#fffefc" }
local LEAF = { "#2d5b3f", "#3f7d4a", "#5fa055", "#86c064", "#b2dc7e" }
local MARK, TWIG = "#3b3340", "#8a7a7c"
c:groundShadow(32, 55, 11, 2)
-- grass tufts
for _, g in ipairs{ {24,55},{26,54},{40,55},{42,54},{43,55} } do c:px(g[1], g[2], LEAF[2]) end
for _, g in ipairs{ {25,54},{41,54} } do c:px(g[1], g[2], LEAF[4]) end
-- branches
local br = {
  { {31,26},{27,22},{22,22},{17,24},{14,28} },
  { {34,19},{39,16},{45,16},{49,19},{51,24} },
  { {32,13},{28,10},{24,10},{21,13} },
}
for _, b in ipairs(br) do G.line(c, b, TWIG) end
-- trunk
local tm, tn = G.tube({ {31,55},{35,41},{29,27},{33,9} }, function(t) return 3.2 - 1.9 * t end)
G.tone(c, tm, X.light(tn, { amb = 0.15, wrap = 0.3 }), BARK, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- lenticel dashes + dark roots
for _, y in ipairs{ 54, 49, 44, 39, 34, 29, 24, 19, 15 } do
  tm:each(function(x, yy)
    if yy == y and X.hash(x, y, 7) > 0.35 and x % 4 ~= 3 then c:px(x, yy, MARK) end
  end)
end
tm:each(function(x, y) if y >= 52 and X.hash(x, y, 9) > 0.55 then c:px(x, y, BARK[1]) end end)
-- quirk: peeling bark curl
for _, p in ipairs{ {35,37},{36,36},{37,36},{38,37},{37,38} } do c:px(p[1], p[2], BARK[5]) end
c:px(36, 37, BARK[2]) c:px(37, 37, BARK[1]) c:px(35, 38, BARK[2])
-- hanging twigs, leaves, catkins
local tw = { {22,22,5},{17,24,6},{14,28,5},{27,23,3},{39,16,4},{45,16,6},{49,19,6},{51,24,5},{24,10,5},{21,13,6},{28,10,3} }
local function leaf(x, y)
  local m = c:poly{ { x, y - 3 }, { x + 2, y }, { x, y + 3 }, { x - 2, y } }
  m:each(function(px, py)
    local i = (px < x and py <= y) and 4 or ((px > x and py > y) and 2 or 3)
    c:px(px, py, LEAF[i])
  end)
  c:px(x, y, LEAF[2]) c:px(x, y - 1, LEAF[2]) c:px(x - 1, y - 1, LEAF[5])
end
for i, t in ipairs(tw) do
  G.line(c, { {t[1], t[2]}, {t[1], t[2] + t[3]} }, TWIG)
  leaf(t[1] - 2, t[2] + 2 + (i % 2)) leaf(t[1] + 1, t[2] + t[3] + 1)
end
for _, k in ipairs{ {31,26},{34,19} } do
  for j = 1, 4 do c:px(k[1] + 1, k[2] + j, j % 2 == 0 and "#c9a45a" or "#e3c97a") end
end
G.fin(c, "silver-birch")
