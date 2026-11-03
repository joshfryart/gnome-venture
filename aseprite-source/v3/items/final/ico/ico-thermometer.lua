local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-thermometer: bold glass thermometer, red mercury in a round bulb, gold ticks.
-- quirk: a little striped scarf knotted round the tube.
local c = D.new("ico-thermometer")
local glass = c:rrect(26, 6, 37, 44, 5):add(c:ellipse(31.5, 46, 10, 10))
D.lit(c, glass, D.ICE, 4)
local hg = c:rrect(29, 14, 34, 44, 2):add(c:ellipse(31.5, 46, 7, 7))
D.lit(c, hg, D.RED, 3)
c:fillMask(c:rect(29, 12, 34, 14), D.ICE[5])
for i, y in ipairs{ 12, 18, 24, 30 } do c:fillMask(c:rect(40, y, i % 2 == 1 and 46 or 43, y + 1), D.GOLD[4]) end
c:fillMask(c:rect(29, 36, 30, 39), D.RED[6]) c:px(33, 52, D.RED[6])
local sc = c:rrect(23, 31, 40, 36, 2)
D.lit(c, sc, D.PINK, 2)
for x = 25, 38, 4 do c:fillMask(c:rect(x, 31, x + 1, 36), D.CRM[4]) end
D.lit(c, c:rrect(37, 34, 41, 45, 1), D.PINK, 2)
c:fillMask(c:rect(38, 42, 40, 43), D.CRM[4])
c:sparkle(14, 16)
D.fin()
