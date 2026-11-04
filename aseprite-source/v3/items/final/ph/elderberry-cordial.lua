-- elderberry-cordial (first draft, Sonnet)
-- quirk: a small berry sprig is tied to the bottle neck with twine
local NAME = "elderberry-cordial"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB25.lua")
local H, HP = D.H, D.HP
local X, K = D.X, D.K
local floor, sin, cos, max, min, abs, pi = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.pi
local c = D.new(NAME)
c:groundShadow(32, 58, 15, 3)
local GL = D.rp("#1a0a2a", "#4a1a6a", "#b87ae0")
local bottle = c:poly{ { 26, 56 }, { 19, 52 }, { 18, 34 }, { 26, 26 }, { 26, 16 }, { 38, 16 }, { 38, 26 }, { 46, 34 }, { 45, 52 }, { 38, 56 } }
D.blob(bottle, GL, 7)
-- pale glass rim on the left and glint
for y = 36, 50 do c:px(21, y, "#d8b8f0") end
c:px(23, 30, "#f0e0ff") c:px(23, 31, "#f0e0ff") c:px(22, 40, "#f0e0ff")
-- liquid line
c:fillMask(c:rect(19, 33, 44, 33):clip(bottle), "#8a4ab8")
-- cork
D.blob(c:rect(27, 9, 37, 16), D.rp("#5a3a1a", "#b8844a", "#f0c88a"), 2)
c:px(29, 11, "#f8e0a8") c:px(30, 11, "#f8e0a8")
-- label
c:fillMask(c:rect(23, 40, 41, 50), "#f6e8c8") c:fillMask(c:rect(23, 50, 41, 50), "#c8a878")
D.bead(32, 45, 2.5, D.rp("#120a2a", "#2e1a5a", "#7a6ac8"), "#b8b0f0")
c:px(35, 42, "#3a8a46") c:px(36, 42, "#3a8a46") c:px(35, 43, "#3a8a46")
-- drip
for y = 38, 42 do c:px(44, y, "#8a4ab8") end
-- twine + sprig
for x = 26, 38 do c:px(x, 25, x % 2 == 0 and "#c8a060" or "#8a6a38") end
D.bead(40, 27, 2, D.rp("#120a2a", "#2e1a5a", "#7a6ac8")) D.bead(43, 29, 2, D.rp("#120a2a", "#2e1a5a", "#7a6ac8"))
D.leaf(46, 24, 4, 1.8, -0.7, D.LEAF, true)
D.fin()
