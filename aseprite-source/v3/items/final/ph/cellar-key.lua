-- cellar-key (v3 first draft, dB15). quirk: a little wooden tag with a C scratched in hangs from the bow
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cellar-key")
local IR = { "#2a2a3c", "#444663", "#62647c", "#8c8ca4", "#b8b8c8", "#e2e0e6" }
local bow = B.ell(26, 12, 5.5, 5.5, 0):add(B.ell(37, 12, 5.5, 5.5, 0)):add(B.ell(31.5, 7, 5.5, 5.5, 0)):add(B.ell(31.5, 17, 5, 5, 0))
local holes = B.ell(26, 12, 2, 2, 0):add(B.ell(37, 12, 2, 2, 0)):add(B.ell(31.5, 7, 2, 2, 0))
bow:cut(holes)
H.lit(c, bow, IR, { R = 2.2 })
-- shaft
local sh = c:rect(30, 20, 33, 52)
H.vcyl(c, sh, IR, 30, 34)
-- collars
for _, y in ipairs{ 22, 29 } do local m = c:rect(28, y, 35, y + 1) H.lit(c, m, IR, { R = 1 }) end
-- bit with teeth
local bit = c:rect(34, 40, 44, 52):cut(c:rect(38, 40, 40, 43)):cut(c:rect(40, 47, 42, 49)):cut(c:rect(36, 49, 37, 52))
H.lit(c, bit, IR, { R = 1.6 })
c:fillMask(c:rect(31, 50, 32, 51), "#444663")
-- rust specks
for _, p in ipairs{ {31, 35}, {32, 44}, {41, 51}, {33, 14} } do c:px(p[1], p[2], "#a2602e") end
c:px(31, 36, "#d08a46")
-- tag on a string
B.ln(c, 40, 15, 46, 22, "#c9a46a")
local tag = c:rect(42, 22, 50, 31):cut(c:rect(42, 22, 42, 22))
H.lit(c, tag, "wood", { R = 1.5 })
c:px(44, 25, "#51302b") c:px(45, 24, "#51302b") c:px(46, 25, "#51302b") c:px(44, 26, "#51302b") c:px(45, 27, "#51302b") c:px(46, 27, "#51302b")
c:px(46, 22, "#2b1c26")
D.fin()
