local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-desert: sand dunes, a bold saguaro cactus and a low gold sun.
-- quirk: the cactus has a pink flower on top and a tiny bleached skull sits at its foot.
local c = D.new("ico-desert")
-- sun
D.lit(D.disc(46, 20, 11), D.GOLD, 5, {})
for i = 0, 7 do local a = i * pi / 4 D.fill(c:line({ { 46 + cos(a) * 14, 20 + sin(a) * 14 }, { 46 + cos(a) * 18, 20 + sin(a) * 18 } }, 2), D.GOLD[4]) end
-- dunes
local back = c:poly{ { 4, 50 }, { 20, 40 }, { 36, 44 }, { 60, 36 }, { 60, 58 }, { 4, 58 } }
D.lit(back, { "#8a5a3a", "#b88050", "#d9a468", "#ecbe80", "#f6d49a", "#fde8b8" }, 8)
local front = c:poly{ { 4, 56 }, { 22, 50 }, { 44, 54 }, { 60, 50 }, { 60, 60 }, { 4, 60 } }
D.lit(front, { "#7a4a30", "#a46c42", "#c88e58", "#e0a868", "#f0c488", "#fbdca8" }, 4)
-- cactus
local cac = D.sub(c:rrect(26, 14, 34, 54, 4), c:rect(0, 0, 0, 0))
cac:add(c:rrect(14, 28, 18, 38, 2)):add(c:rect(14, 36, 27, 40)):add(c:rrect(42, 22, 46, 34, 2)):add(c:rect(34, 32, 45, 36))
D.lit(cac, D.GREEN, 3.5)
for _, y in ipairs{ 20, 26, 32, 38, 44 } do D.px(30, y, D.GREEN[5]) end
D.fill(c:rect(30, 16, 30, 52), D.GREEN[2])
D.fill(c:rect(31, 16, 31, 52), D.GREEN[3])
-- flower
D.lit(D.disc(30, 11, 3), D.P.petal, 2)
D.px(30, 11, D.GOLD[5])
-- skull
D.lit(D.ell(50, 53, 3.4, 2.8), D.CREAM, 2)
D.px(49, 53, D.INK) D.px(51, 53, D.INK)
D.fin()
