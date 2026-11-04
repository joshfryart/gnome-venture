-- sorrel (lean W2_20)
-- Upright sorrel sprig: red-streaked stem, big hastate (arrow) leaf on top with two swept-back lobes, small lance leaf low right, dewdrop quirk.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sorrel" }
local abs, floor = math.abs, math.floor
local LEAF = { "#1b3b3c", "#255644", "#3a7f4a", "#5ba452", "#86c262", "#b8dc86" }
local STEM = { "#5a1f35", "#8a2f45", "#b8485a", "#d98a7a" }
local lt = { r = { name = "leaf" } }
c:groundShadow(32, 55, 9, 2)
-- stem
c:fillMask(c:line({ {32, 54}, {32, 40}, {31, 28}, {32, 20} }, 2), STEM[2])
c:fillMask(c:line({ {31, 54}, {31, 40}, {30, 28} }, 1), STEM[3])
c:fillMask(c:line({ {33, 54}, {33, 42} }, 1), STEM[1])
-- small lance leaf low right
local sm = c:poly{ {32,44},{36,40},{42,37},{49,36},{54,37},{50,41},{44,45},{38,47} }
local sn = X.pillow(sm, 4)
G.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.25 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, lt)
G.line(c, { {33,44},{40,41},{48,38},{53,37} }, LEAF[6])
-- big hastate leaf: tip at top, lobes swept down/out
local big = c:poly{ {32,6},{36,10},{39,15},{41,19},{47,21},{54,25},{57,32},{50,28},{43,28},{38,29},{34,30},{30,30},{26,29},{21,28},{14,28},{7,32},{10,25},{17,21},{23,19},{25,15},{28,10} }
local bn = X.pillow(big, 6)
G.tone(c, big, X.light(bn, { amb = 0.1, wrap = 0.25 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, lt)
-- midrib and veins
G.line(c, { {32,8},{32,20},{32,30} }, LEAF[6])
G.line(c, { {32,22},{22,26},{12,29} }, LEAF[5]) G.line(c, { {32,22},{42,26},{52,29} }, LEAF[2])
for _, y in ipairs{ 12, 16 } do
  G.line(c, { {32,y+2},{28,y-1} }, LEAF[5]) G.line(c, { {32,y+2},{36,y-1} }, LEAF[2])
end
-- notch shade where lobes meet stem
c:px(31, 30, LEAF[1]) c:px(33, 30, LEAF[1]) c:px(32, 31, STEM[1])
-- dewdrop quirk
c:fillMask(c:ellipse(38, 17, 1, 1), "#bfe6f2") c:px(37, 16, "#fffaf0") c:px(39, 18, "#5aa0c8")
G.fin(c, "sorrel")
