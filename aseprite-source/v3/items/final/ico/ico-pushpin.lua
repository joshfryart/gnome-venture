local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-pushpin: glossy pink pushpin, domed cap, narrow neck and flat base on a steel needle.
-- quirk: the needle tip is bent sideways like it met a very hard wall.
local c = D.new("ico-pushpin")
local needle = D.cyl(c, 32, 38, 32, 54, function(t) return max(0.5, 1.8 * (1 - t * 0.7)) end, D.GRY, { amb = 0.1 })
D.polyline(c, { {32, 54}, {34, 56}, {38, 57} }, D.GRY[4])
D.polyline(c, { {31, 54}, {33, 57}, {38, 58} }, D.GRY[2])
local base = c:rrect(17, 32, 47, 38, 2)
D.lit(c, base, D.PINK, 3, { amb = 0.15 })
D.rect(c, 17, 38, 47, 38, D.PINK[1])
local neck = c:rrect(24, 22, 40, 32, 1)
D.lit(c, neck, D.PINK, 4, { amb = 0.15 })
local cap = c:rrect(18, 6, 46, 22, 6)
D.lit(c, cap, D.PINK, 8, { amb = 0.05 })
D.rect(c, 22, 8, 25, 9, D.PINK[6]) D.rect(c, 22, 10, 23, 12, D.PINK[6])
D.rect(c, 24, 31, 40, 31, D.PINK[1])
D.fin()
