local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-thumbs-up: chunky fist with the thumb high, blue cuff.
-- quirk: a tiny gold star on the thumbnail.
local c = D.new("ico-thumbs-up")
D.lit(c, c:rrect(8, 32, 18, 57, 2), D.BLU, 3)
c:fillMask(c:rect(8, 32, 9, 57), D.BLU[5])
local fist = c:rrect(20, 30, 52, 57, 7)
D.lit(c, fist, D.SKIN, 6)
local th = c:rrect(24, 8, 36, 38, 5)
D.lit(c, th, D.SKIN, 4)
c:fillMask(c:rrect(27, 10, 33, 17, 2), D.SKIN[6])
c:fillMask(D.star(c, 30, 13, 3, 1, 5), D.GOLD[5])
for _, y in ipairs{ 38, 44, 50 } do c:fillMask(c:rect(39, y, 52, y), D.SKIN[2]) c:fillMask(c:rect(39, y + 1, 52, y + 1), D.SKIN[5]) end
c:fillMask(c:rect(37, 38, 38, 55), D.SKIN[2])
c:sparkle(50, 18)
D.fin()
