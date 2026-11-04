-- nav-start (dC25 first draft, Sonnet). A fresh seedling with two big leaves and a golden bud rising from a dark soil mound. quirk: the left leaf still wears its seed coat as a tiny brown hat.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-start") local B, R, HP = D.B, D.R, D.HP
B.lit(c, c:ellipse(32, 53, 22, 6), R.brown, 5)
D.line(c, {{22, 53}, {42, 53}}, 1, R.brown[1])
B.ln(c, 32, 50, 32, 24, R.leaf[3]) B.ln(c, 33, 50, 33, 26, R.leaf[4]) B.ln(c, 34, 50, 34, 30, R.leaf[5])
B.lit(c, B.ell(20, 33, 11, 5, -.6), R.sprout, 3) B.lit(c, B.ell(45, 31, 11, 5, .6), R.sprout, 3)
B.ln(c, 12, 38, 28, 30, R.sprout[6]) B.ln(c, 52, 36, 37, 29, R.sprout[6])
B.lit(c, c:ellipse(32.5, 19, 5, 5), R.gold, 3) c:px(31, 17, R.cream[6])
B.lit(c, c:ellipse(11, 41, 3, 2), R.brown, 1.4)
D.fin()
