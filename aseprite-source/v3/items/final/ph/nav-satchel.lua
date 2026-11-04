-- nav-satchel (dC25 first draft, Sonnet). Leather satchel with a flap, gold buckle and one run of gold stitch. quirk: a green sprig and a rolled letter poke out the top.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-satchel") local B, R, HP = D.B, D.R, D.HP
D.shadow(c, 32, 59, 20, 2)
B.ln(c, 22, 20, 18, 10, R.leaf[3]) B.ln(c, 23, 20, 20, 10, R.leaf[4]) B.lit(c, B.ell(17, 9, 3, 2, -.8), R.sprout, 1.4) B.lit(c, B.ell(21, 8, 3, 2, .8), R.sprout, 1.4)
D.rod(c, {{40, 24}, {50, 8}}, 3, R.paper, 1.5)
D.rod(c, {{22, 26}, {20, 14}, {32, 8}, {44, 14}, {42, 26}}, 3, "wood", 1.5)
B.lit(c, c:rrect(8, 24, 56, 57, 6), "wood", 6)
B.lit(c, c:poly{{8, 24}, {56, 24}, {56, 34}, {32, 46}, {8, 34}}, R.brown, 4)
c:stitch({{12, 30}, {32, 41}, {52, 30}})
B.lit(c, c:rrect(28, 40, 36, 50, 1), R.gold, 2) c:fillMask(c:rect(31, 43, 33, 46), R.gold[1])
D.fin()
