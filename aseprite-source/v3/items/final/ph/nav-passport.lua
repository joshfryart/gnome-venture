-- nav-passport (dC25 first draft, Sonnet). Blue travel passport with a gold globe emblem and a red round stamp. quirk: the stamp ring is half off the cover edge, a stray ticket corner pokes out.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-passport") local B, R, HP = D.B, D.R, D.HP
B.lit(c, c:rect(46, 9, 52, 55), R.paper, 2)
B.lit(c, c:rrect(11, 6, 48, 57, 4), R.blue, 5)
B.lit(c, c:ellipse(30, 24, 10, 10), R.gold, 5)
D.line(c, {{20, 24}, {40, 24}}, 1, R.gold[2]) D.line(c, {{30, 14}, {30, 34}}, 1, R.gold[2])
c:fillMask(c:ellipse(30, 24, 4, 10):cut(c:ellipse(30, 24, 2, 10)), R.gold[2])
D.line(c, {{19, 40}, {41, 40}}, 2, R.blue[6])
B.lit(c, c:ellipse(37, 49, 6, 6), R.red, 1) c:fillMask(c:ellipse(37, 49, 3, 3), R.blue[3])
B.lit(c, c:poly{{44, 3}, {52, 3}, {52, 12}}, R.paper, 1.5)
D.fin()
