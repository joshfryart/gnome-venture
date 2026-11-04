-- nav-almanac (dC25 first draft, Sonnet). Upright green almanac with a cream label showing a sprout and a red ribbon. quirk: a pressed leaf pokes out of the pages.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-almanac") local B, R, HP = D.B, D.R, D.HP
B.lit(c, c:rect(46, 10, 52, 54), R.paper, 2)
B.lit(c, c:rrect(12, 7, 48, 57, 3), "moss", 4)
D.line(c, {{16, 8}, {16, 56}}, 2, "#24544a")
B.lit(c, c:rrect(21, 15, 43, 39, 2), R.paper, 2)
-- sprout label
B.ln(c, 32, 36, 32, 25, R.leaf[4]) B.lit(c, B.ell(28, 25, 4, 2.2, -.5), R.sprout, 1.5) B.lit(c, B.ell(36, 23, 4, 2.2, .5), R.sprout, 1.5)
D.line(c, {{24, 44}, {40, 44}}, 2, R.gold[4]) D.line(c, {{26, 49}, {38, 49}}, 1, R.gold[3])
-- ribbon
B.lit(c, c:poly{{38, 56}, {38, 63}, {41, 60}, {44, 63}, {44, 56}}, R.red, 1.5)
-- pressed leaf
B.lit(c, B.ell(52, 24, 4, 2.2, .7), R.brown, 1.4) c:px(52, 24, R.gold[5])
D.fin()
