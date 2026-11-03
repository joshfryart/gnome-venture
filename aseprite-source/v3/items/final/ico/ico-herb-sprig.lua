local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-herb-sprig: slim herb stem with paired lance leaves. quirk: a tiny blue flower bud on top and a dewdrop on a leaf.
local c = D.new("ico-herb-sprig")
D.lit(D.c:line({ { 32, 58 }, { 32, 12 } }, 3), D.GREEN, 1.5, { amb = 0.2 })
D.fill(D.rect(31, 14, 31, 56), D.GREEN[3])
local ys = { 46, 38, 30, 22 }
for i, y in ipairs(ys) do
  local l = 12 - (i - 1) * 1
  D.leaf(32, y + 3, 32 - 17 + (i - 1) * 2, y - 6, 4, "moss", { 5, 9 })
  D.leaf(32, y, 32 + 17 - (i - 1) * 2, y - 9, 4, "moss", { 5, 9 })
end
D.leaf(32, 18, 32, 4, 3, "moss")
-- bud
D.lit(D.disc(32, 6, 3), D.BLUE, 3) D.px(31, 5, D.CR)
-- dew
D.fill(D.rect(44, 34, 45, 35), D.BLUE[5]) D.px(44, 34, D.CR)
D.fin()
