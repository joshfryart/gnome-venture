local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-undo: fat counter-clockwise arrow in blue, head at the upper left.
-- quirk: the tail ends in a little pink pencil eraser with a metal band.
local c = D.new("ico-undo")
local pts = D.arc(31, 34, 16, 20, -180, 24)
local m = D.swept(c, pts, function() return 3.4 end)
D.lit(c, m, D.BLU, 3)
local e = pts[#pts]
D.lit(c, c:poly{ {6, 34}, {26, 34}, {16, 48} }, D.BLU, 3)
c:fillMask(c:rect(10, 34, 20, 34), D.BLU[2])
local s = pts[1]
D.lit(c, c:rrect(floor(s[1]) - 1, floor(s[2]) + 1, floor(s[1]) + 6, floor(s[2]) + 10, 2), D.PINK, 2)
c:fillMask(c:rect(floor(s[1]) - 1, floor(s[2]) + 4, floor(s[1]) + 6, floor(s[2]) + 5), D.GRY[4])
c:sparkle(50, 14)
D.fin()
