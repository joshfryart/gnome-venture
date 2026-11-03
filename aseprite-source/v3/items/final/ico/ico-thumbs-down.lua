local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-thumbs-down: grumpy fist, thumb pointing down, red cuff, dusky skin tone.
-- quirk: a nervous sweat drop beside the thumb.
local c = D.new("ico-thumbs-down")
local SK = { "#5e2c2c", "#8e4a3a", "#bd6e4c", "#d98e62", "#eeb088", "#ffd0aa" }
D.lit(c, c:rrect(8, 6, 18, 31, 2), D.RED, 3)
c:fillMask(c:rect(8, 6, 9, 31), D.RED[5])
local fist = c:rrect(20, 6, 52, 33, 7)
D.lit(c, fist, SK, 6)
local th = c:rrect(24, 25, 36, 56, 5)
D.lit(c, th, SK, 4)
c:fillMask(c:rrect(27, 48, 33, 55, 2), SK[6])
for _, y in ipairs{ 13, 19, 25 } do c:fillMask(c:rect(39, y, 52, y), SK[2]) c:fillMask(c:rect(39, y + 1, 52, y + 1), SK[5]) end
c:fillMask(c:rect(37, 8, 38, 26), SK[2])
local dr = c:ellipse(47, 48, 4, 5):add(c:poly{ {47, 38}, {43, 45}, {51, 45} })
D.lit(c, dr, D.ICE, 2)
c:px(45, 47, CREAM)
D.fin()
