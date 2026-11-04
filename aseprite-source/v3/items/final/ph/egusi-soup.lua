-- egusi-soup (first draft, Sonnet)
-- quirk: a wooden spoon rests in the bowl, a golden drip sliding off its tip
local NAME = "egusi-soup"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB25.lua")
local H, HP = D.H, D.HP
local X, K = D.X, D.K
local floor, sin, cos, max, min, abs, pi = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.pi
local c = D.new(NAME)
c:groundShadow(32, 57, 21, 3)
local BW = D.rp("#5a1a14", "#b8482a", "#f0a070")
-- soup surface
local SP = D.rp("#8a3a0a", "#e08a1a", "#ffd870")
local top = D.el(32, 36, 20, 8, 0, SP, 6)
-- curds, greens, meat
for _, p in ipairs{ { 22, 34 }, { 28, 38 }, { 38, 34 }, { 42, 38 }, { 32, 33 } } do D.el(p[1], p[2], 3, 1.8, 0, D.rp("#a8801a", "#f0d060", "#fffbc0"), 1.6) end
for _, p in ipairs{ { 26, 32 }, { 36, 38 }, { 18, 38 } } do D.leaf(p[1], p[2], 3.5, 1.8, 0.4, D.LEAF, false) end
D.el(33, 36, 3, 2.2, 0, D.rp("#4a1a10", "#9a4a2a", "#d89a6a"), 2)
-- bowl
local bowl = c:poly{ { 10, 38 }, { 54, 38 }, { 48, 54 }, { 40, 57 }, { 24, 57 }, { 16, 54 } }
bowl:cut(top)
D.blob(bowl, BW, 8)
c:fillMask(c:rect(18, 49, 46, 50), "#e8c8a0")
-- spoon
D.stem({ { 44, 34 }, { 50, 20 }, { 55, 8 } }, "#c8905a", "#7a4a2a", 2)
D.el(43, 36, 4, 2.4, -0.4, D.rp("#5a3a1a", "#b8844a", "#f0c88a"), 2)
c:px(55, 14, "#ffd870") c:px(56, 15, "#e08a1a")
-- steam
for _, p in ipairs{ { 22, 22 }, { 23, 20 }, { 22, 18 }, { 21, 16 }, { 30, 20 }, { 31, 18 }, { 30, 16 }, { 29, 14 } } do c:px(p[1], p[2], "#fff0d8") end
D.fin()
