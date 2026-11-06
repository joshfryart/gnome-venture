-- soil-probe (lean D2o_2)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "soil-probe" }
local function shade(m, ramp, R, bias, cuts) local n = X.pillow(m, R) return G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), ramp, cuts, bias) end
-- soil probe: wooden ring handle, brass collar, steel sampling tube with a slot window showing layered soil core, pointed tip (quirk: the soil core)
local WOOD  = { "#3a2214", "#5e3a1e", "#84552c", "#aa7a40", "#cca05c", "#e8c47c" }
local STEEL = { "#3c4458", "#5c6a82", "#8496ae", "#acc0d4", "#d0e0ee", "#f4faff" }
local BRASS = { "#6a4418", "#a06a24", "#d49a3c", "#f0c668" }
local DIRT  = { "#2e1c14", "#4a2e1e", "#6c4630", "#8e6444", "#b08460" }
c:groundShadow(32, 56, 9, 2)
local ring = c:ellipse(32, 11, 11, 7) ring:cut(c:ellipse(32, 11, 5, 3))
shade(ring, WOOD, 4)
for _, p in ipairs{ {24, 9}, {40, 13}, {27, 16}, {37, 7} } do c:px(p[1], p[2], WOOD[2]) end
c:px(25, 7, WOOD[6]) c:px(26, 6, WOOD[6]) c:px(27, 6, WOOD[5])
-- shaft
local m, n = X.cyl(32, 17, 32, 52, function(t) if t > 0.995 then return -1 end if t < 0.82 then return 3.3 end return max(0.4, 3.3 * (1 - t) / 0.18) end)
G.tone(c, m, X.light(n, { amb = 0.14, wrap = 0.3 }), STEEL, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- brass collar
local col = c:rect(28, 16, 36, 19) shade(col, BRASS, 3)
-- depth ticks on the left edge
for _, y in ipairs{ 22, 26, 30, 34, 38, 42, 46 } do c:px(29, y, STEEL[1]) c:px(30, y, STEEL[1]) end
-- window with soil core
c:fillMask(c:rect(31, 23, 34, 41), DIRT[1])
local layers = { {24, 28, 4}, {29, 33, 3}, {34, 37, 5}, {38, 40, 2} }
for _, L in ipairs(layers) do c:fillMask(c:rect(32, L[1], 33, L[2]), DIRT[L[3]]) end
c:px(32, 25, DIRT[5]) c:px(33, 31, DIRT[2]) c:px(32, 36, DIRT[3])
-- steel spec
for y = 20, 48 do if y < 23 or y > 41 then c:px(30, y, STEEL[6]) end end
c:px(31, 22, STEEL[1]) c:px(32, 22, STEEL[1]) c:px(33, 22, STEEL[1])
-- soil clump at the tip
shade(c:ellipse(32, 55, 8, 2), DIRT, 3)
for _, p in ipairs{ {26, 53}, {39, 54}, {37, 52} } do c:px(p[1], p[2], DIRT[4]) end
G.fin(c, "soil-probe")
