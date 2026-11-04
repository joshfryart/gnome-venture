-- nav-gnome (dC25 first draft, Sonnet). Round gnome face under a red hat with a white bobble, big nose and a long white beard. quirk: a gold patch is sewn on the hat.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-gnome") local B, R, HP = D.B, D.R, D.HP
B.lit(c, c:poly{{14, 38}, {50, 38}, {32, 60}}, R.beard, 4)
B.lit(c, c:poly{{14, 32}, {50, 32}, {38, 12}, {35, 6}, {31, 8}, {27, 20}}, R.red, 5)
B.lit(c, c:ellipse(34, 6, 3.5, 3.5), R.beard, 2)
B.lit(c, c:ellipse(32, 36, 14, 8), R.skin, 5)
B.lit(c, c:rect(13, 30, 51, 34), R.red, 1.5)
c:fillMask(c:rect(36, 20, 40, 24), R.gold[4]) D.line(c, {{36, 20}, {40, 20}}, 1, R.gold[6])
c:eyeSmall(23, 34) c:eyeSmall(38, 34)
B.lit(c, c:ellipse(32, 41, 4, 3), R.skin, 2) c:px(31, 40, R.cream[6])
B.lit(c, c:ellipse(32, 47, 9, 3), R.beard, 2)
D.fin()
