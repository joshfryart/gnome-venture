-- ico-pancakes first draft (Sonnet). quirk: the top pancake has a butter pat sliding off on its own syrup trail
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-pancakes")
c:groundShadow(32, 58, 25, 3)
-- plate
D.lit(D.ell(32, 52, 25, 6), "stone", 3)
D.fill(D.ell(32, 51, 20, 4), "#e2e0e6")
local PC = { "#8a4a26", "#b8702f", "#d6903f", "#eeae58", "#f8c874", "#ffe3a0" }
local SIDE = { "#c9a98a", "#e6cfa8", "#f2d9a8", "#fbe6b8", "#fff0cc", "#fffbe8" }
for i = 0, 2 do
  local y = 45 - i * 8
  D.lit(c:rrect(10, y - 3, 53, y + 4, 3), SIDE, 3)
  D.fill(c:rect(11, y, 52, y + 1), "#d6903f") D.fill(c:rect(11, y + 2, 52, y + 3), "#8a4a26")
end
-- top face
D.lit(D.ell(32, 22, 23, 6), PC, 4)
-- syrup
local sy = D.ell(32, 22, 17, 5):add(c:rect(14, 22, 22, 28)):add(c:rect(36, 22, 40, 33)):add(c:rect(47, 22, 51, 30))
sy:cut(D.ell(32, 22, 17, 5):copy():cut(D.ell(32, 22, 17, 5):shrink(0)))
local syr = D.ell(32, 23, 17, 5)
D.lit(syr, { "#3a1a10", "#6a2e14", "#9a4a18", "#c26a24", "#e08a30", "#ffb050" }, 2.5)
for _, d in ipairs{ {16, 27, 28}, {38, 28, 34}, {49, 27, 31} } do
  D.fill(c:rect(d[1], d[2] - 3, d[1] + 2, d[3]), "#9a4a18") D.fill(c:rect(d[1], d[3] - 1, d[1] + 2, d[3] + 1), "#c26a24") c:px(d[1], d[2] + 1, "#e08a30")
end
-- butter pat
D.lit(c:rect(24, 14, 36, 20), { "#d8a830", "#e8c040", "#f6d860", "#fbe680", "#fff0a0", "#fffad0" }, 2)
D.fill(c:rect(24, 20, 36, 20), "#d8a830") D.fill(c:rect(37, 17, 38, 20), "#f6d860")
D.fin()
