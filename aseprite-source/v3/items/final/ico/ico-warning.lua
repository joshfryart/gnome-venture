local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-warning: chunky yellow warning triangle with rounded corners and a dark bold bang.
-- quirk: the dot of the exclamation mark is a little red ladybug.
local c = D.new("ico-warning")
local t = c:poly{ {32, 6}, {58, 52}, {6, 52} }
t:add(c:ellipse(32, 9, 4, 4)):add(c:ellipse(55, 50, 4, 4)):add(c:ellipse(9, 50, 4, 4)):add(c:rect(9, 50, 55, 54))
D.lit(c, t, D.YEL, 7)
c:fillMask(c:poly{ {32, 14}, {50, 46}, {14, 46} }, D.YEL[3])
D.lit(c, c:poly{ {32, 15}, {49, 46}, {15, 46} }, D.YEL, 5, { amb = 0.2 })
c:fillMask(c:rrect(29, 22, 35, 37, 2), D.BRN[2])
c:fillMask(c:rect(29, 23, 30, 35), D.BRN[3])
D.lit(c, c:ellipse(32, 43, 3, 2.5), D.RED, 2)
c:px(32, 41, INK) c:px(32, 44, INK) c:px(31, 42, CREAM)
D.fin()
