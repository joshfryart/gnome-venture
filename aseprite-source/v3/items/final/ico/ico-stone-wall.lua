local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-stone-wall: a short dry-stone wall, three courses of mismatched grey blocks with dark mortar.
-- quirk: moss creeps over the top-left block and a tiny pink flower grows from a gap on top.
local c = D.new("ico-stone-wall")
c:groundShadow(32, 54, 26, 2)
local rows = {
  { 12, 24, { 8, 22, 36, 50 }, { 20, 34, 48, 56 } },
  { 25, 37, { 8, 16, 32, 46 }, { 14, 30, 44, 56 } },
  { 38, 50, { 8, 24, 38, 50 }, { 22, 36, 48, 56 } },
}
local tones = { D.GRY, D.PURP, D.GRY }
for ri, r in ipairs(rows) do
  for i = 1, #r[3] do
    D.lit(c, c:rrect(r[3][i], r[1], r[4][i], r[2], 2), (i + ri) % 3 == 0 and D.PURP or D.GRY, 4, { amb = 0.1 })
  end
end
-- mortar lines between blocks
for _, r in ipairs(rows) do for i = 2, #r[3] do D.rect(c, r[4][i - 1] + 1, r[1], r[3][i] - 1, r[2], D.GRY[1]) end end
-- moss
D.rect(c, 9, 13, 19, 14, D.GRN[4]) D.rect(c, 9, 15, 13, 16, D.GRN[3]) c:px(15, 15, D.GRN[3]) D.rect(c, 10, 13, 12, 13, D.GRN[6])
-- flower
D.rect(c, 29, 5, 29, 11, D.GRN[3]) D.rect(c, 27, 3, 31, 5, D.PINK[4]) D.rect(c, 28, 2, 30, 6, D.PINK[4]) c:px(29, 4, D.YEL[4])
D.fin()
