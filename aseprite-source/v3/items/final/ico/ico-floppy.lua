local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-floppy: blue floppy disk with metal shutter and a cream label.
-- quirk: the label has a tiny red gnome-hat doodle and the corner is dog-eared.
local c = D.new("ico-floppy")
local body = c:poly{ {9,9},{45,9},{55,19},{55,55},{9,55} }
D.lit(body, D.BLUE, 16, { amb = 0.1 })
local sh = c:rect(19, 9, 43, 25)
D.lit(sh, D.STEEL, 8, { amb = 0.1 })
D.fill(c:rect(35, 12, 39, 22), "#2f3350") D.fill(c:rect(36, 13, 38, 14), "#4d5275")
local lab = c:rect(15, 33, 49, 55)
D.lit(lab, D.CREAM, 12, { amb = 0.05 })
D.fill(c:poly{ {22,41},{26,35},{30,41} }, "#d4403a") D.fill(c:rect(22, 41, 30, 42), "#7a2036")
D.fill(c:rect(33, 37, 44, 38), "#9ea2bf") D.fill(c:rect(33, 41, 41, 42), "#9ea2bf")
D.fill(c:rect(19, 47, 45, 47), "#c9a98a") D.fill(c:rect(19, 50, 38, 50), "#c9a98a")
D.fill(c:rect(49, 47, 53, 52), "#2f3350")
-- dog ear
D.fill(c:poly{ {45,9},{55,19},{45,19} }, "#1c2e5a") D.poly(c, { {45,9},{45,19},{55,19} }, "#78b4ea")
D.fin()
