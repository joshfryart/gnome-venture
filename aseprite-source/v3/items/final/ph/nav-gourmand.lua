-- nav-gourmand (dC25 first draft, Sonnet). A folded cream menu card with a silver spoon laid over it. quirk: the spoon holds a single red sauce drop and a gold star stamp marks the menu.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-gourmand") local B, R, HP = D.B, D.R, D.HP
B.lit(c, c:poly{{8, 22}, {40, 12}, {48, 46}, {14, 56}}, R.paper, 3)
D.line(c, {{15, 28}, {34, 22}}, 1, R.brown[3]) D.line(c, {{17, 34}, {36, 29}}, 1, R.brown[3]) D.line(c, {{19, 41}, {30, 38}}, 1, R.brown[3])
c:fillMask(c:poly{{40, 12}, {48, 46}, {44, 34}}, R.cream[2])
c:sparkle(25, 48)
D.rod(c, {{12, 58}, {38, 30}}, 3, "stone", 1.6)
local sp = B.ell(46, 22, 8, 10, .75) B.lit(c, sp, "stone", 5)
B.lit(c, B.ell(46, 23, 5, 6, .75), R.iron, 3)
c:px(44, 22, R.red[4]) c:px(45, 22, R.red[4]) c:px(45, 23, R.red[5]) c:px(45, 24, R.red[4])
c:px(41, 14, R.cream[6])
D.fin()
