-- elderberry-seed (first draft, Sonnet)
-- quirk: a lone red-purple berry skin is still clinging to one seed
local NAME = "elderberry-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB25.lua")
local H, HP = D.H, D.HP
local X, K = D.X, D.K
local floor, sin, cos, max, min, abs, pi = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.pi
local c = D.new(NAME)
D.scrap{ ax = 6, ay = 55, bx = 55, by = 52, w = 7, ramp = D.rp("#1a4036", "#3a8a48", "#b0e078"), veins = { 9, 18, 27, 36, 45 } }
local SEED = D.rp("#6a4a22", "#c89a50", "#f8e0a0")
D.seeds({ { 15, 52, 3.6, 2.4, 0.3 }, { 24, 54, 3.6, 2.4, -0.4 }, { 35, 51, 3.6, 2.4, 1.2 } }, SEED)
c:px(15, 52, SEED[2]) c:px(24, 54, SEED[2]) c:px(35, 51, SEED[2])
-- clinging berry skin on first seed
c:fillMask(c:rect(12, 50, 13, 51), "#5a2a7a") c:px(13, 52, "#2e1a5a")
-- pinnate serrated sprout
local LF = D.rp("#16402e", "#2f7a46", "#a8dc70")
D.stem({ { 35, 48 }, { 35, 40 }, { 36, 30 }, { 36, 20 } }, "#e0b0b0", "#a04a58", 1)
for _, L in ipairs{ { 30, 40, 5, 2.4, -2.5 }, { 41, 39, 5, 2.4, -0.6 }, { 30, 31, 5, 2.4, -2.5 }, { 42, 30, 5, 2.4, -0.6 }, { 36, 17, 5, 2.6, -1.57 } } do
  D.leaf(L[1], L[2], L[3], L[4], L[5], LF, true)
  c:px(floor(L[1]) + 1, floor(L[2]) - 3, LF[1]) c:px(floor(L[1]) - 2, floor(L[2]) + 2, LF[1])
end
D.fin()
