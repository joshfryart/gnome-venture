-- smoked-trout (lean D2o_1)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, bias, o) local n = X.pillow(m, R) local v = X.light(n, o or { amb = 0.1, wrap = 0.25 }) local k = #ramp - 1 local cuts = {} for i = 1, k do cuts[i] = 0.12 + 0.76 * (i - 1) / max(1, k - 1) end if bias then for k, b in pairs(bias) do bias[k] = floor(b + 0.5) end end G.tone(c, m, v, ramp, cuts, bias) return n, v end
local function tube(c, p, wf, ramp, o) local m, n, T, S = G.tube(p, wf) G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.25 }), ramp) return m, n, T, S end
local function disc(c, x, y, r, hex) c:fillMask(c:ellipse(x, y, r, r), hex) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "smoked-trout" }
local WD = { "#3c2418", "#5e3b22", "#82552f", "#a87442", "#c8965a", "#e6bb84" }
local BK = { "#4a2412", "#7a3c1a", "#a8601f", "#cf8a2c", "#ecb54a", "#ffe08a" }
local BL = { "#8a5a30", "#b98348", "#dca862", "#f0cc8a", "#fbe6b4", "#fff6dc" }
local SM = { "#7a7088", "#a89eb4", "#d2cadc" }
local GR = { "#2a5a34", "#3f8040", "#68a84c", "#9ccd68" }
-- plank
local pl = c:rrect(5, 38, 59, 50, 2)
local pb = {}
shade(c, pl, WD, 6, pb)
for x = 9, 56 do if X.hash(x, 44, 2) > 0.55 then c:px(x, 43 + floor(X.hash(x, 1, 5) * 3), WD[2]) end end
for x = 7, 55 do if x % 7 ~= 0 then c:px(x, 40, WD[5]) end end
-- dill sprig
G.line(c, { {52,44}, {56,42} }, GR[2]) c:px(56, 41, GR[3]) c:px(54, 42, GR[4]) c:px(55, 44, GR[3]) c:px(53, 43, GR[1])
-- fish
local fish = c:ellipse(30, 30, 19, 8):add(c:ellipse(20, 30, 8, 6)):add(c:poly{ {17,26}, {24,23}, {20,35} })
local tail = c:poly{ {46,30}, {57,21}, {55,30}, {57,39} }
local dors = c:poly{ {27,24}, {33,16}, {38,24} }
local bel = c:poly{ {26,36}, {31,41}, {37,36} }
local fb = {}
local all = fish:copy():add(dors):add(tail)
local n = X.pillow(all, 7)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local back, belly = HP.mask(), HP.mask()
all:each(function(x, y) if y > 32 + sin(x * 0.3) * 0.8 and x < 47 then belly:set(x, y) else back:set(x, y) end end)
G.tone(c, back, v, BK, nil, fb)
G.tone(c, belly, v, BL, nil, fb)
-- fin rays
for t = 0, 4 do c:px(29 + t, 21 - floor(t / 2) + 2 + t % 2, BK[2]) end
for y = 22, 38 do if (y % 3 == 0) then c:px(50 + floor((y - 30) * 0.2), y, BK[2]) c:px(53, y, BK[2]) end end
-- spots on back
for _, p in ipairs{ {24,26}, {29,25}, {34,26}, {38,28}, {27,29}, {32,29}, {41,29} } do c:px(p[1], p[2], BK[1]) end
-- gill line, eye, mouth
G.line(c, { {23,26}, {24,30}, {23,34} }, BK[2])
disc(c, 15, 28, 2, BL[5]) c:px(15, 28, BK[1]) c:px(14, 27, BL[6])
G.line(c, { {12,32}, {16,33} }, BK[1])
-- gloss streak along back
G.line(c, { {26,24}, {38,24}, {44,27} }, BK[6])
-- smoke wisps (quirk: forms a fishbone-ish curl)
G.line(c, { {40,13}, {42,10}, {40,7}, {42,5} }, SM[2])
G.line(c, { {47,16}, {49,13}, {47,10} }, SM[2])
c:px(42, 10, SM[3]) c:px(49, 13, SM[3])
G.fin(c, "smoked-trout")
