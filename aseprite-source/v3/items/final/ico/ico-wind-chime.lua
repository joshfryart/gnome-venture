local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-wind-chime: wooden hanger, four hollow gold tubes of different length, a wooden clapper and star sail.
-- quirk: the sail is a little gold star that sways on its own string.
local c = D.new("ico-wind-chime")
D.lit(c, c:rrect(10, 5, 54, 11, 3), D.WOOD, 2)
D.lit(c, c:rrect(28, 2, 36, 5, 1), D.WOOD, 1)
local xs, len = { 12, 23, 34, 45 }, { 24, 32, 28, 36 }
for i, x in ipairs(xs) do
  c:fillMask(c:rect(x + 2, 12, x + 3, 15), CREAM)
  D.lit(c, c:rrect(x, 16, x + 6, 16 + len[i], 2), D.GOLD, 3)
  c:fillMask(c:rect(x + 2, 16 + len[i] - 1, x + 4, 16 + len[i] - 1), D.GOLD[1])
end
c:fillMask(c:rect(31, 12, 32, 40), CREAM)
D.lit(c, c:ellipse(32, 44, 4, 4), D.WOOD, 2)
c:fillMask(c:rect(31, 48, 32, 52), CREAM)
D.lit(c, D.star(c, 32, 56, 4, 2, 5), D.YEL, 1)
c:sparkle(56, 40)
D.fin()
