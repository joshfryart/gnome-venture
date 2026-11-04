-- nav-today (dC25 first draft, Sonnet). Cosy cottage with a red roof, round-top door, window and chimney. quirk: chimney smoke curls into a little heart.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-today") local B, R, HP = D.B, D.R, D.HP
D.shadow(c, 32, 58, 24, 2)
B.lit(c, c:rect(40, 14, 48, 28), "stone", 2)
B.lit(c, c:rect(12, 29, 52, 57), R.paper, 4)
B.lit(c, c:poly{{5, 31}, {32, 8}, {59, 31}, {52, 31}, {32, 15}, {12, 31}}, R.red, 3)
B.lit(c, c:poly{{4, 33}, {32, 10}, {60, 33}, {52, 33}, {32, 18}, {12, 33}}, R.red, 3)
B.lit(c, c:rrect(27, 38, 37, 58, 4):clip(c:rect(0, 0, 63, 57)), "wood", 3) c:px(35, 49, R.gold[5])
B.lit(c, c:rect(16, 38, 24, 46), R.sky, 3) c:fillMask(c:rect(19, 38, 20, 46), R.wood and R.brown[3] or "#b97a4a") c:fillMask(c:rect(16, 41, 24, 42), R.brown[3])
B.lit(c, c:rect(40, 38, 48, 46), R.sky, 3) c:fillMask(c:rect(43, 38, 44, 46), R.brown[3]) c:fillMask(c:rect(40, 41, 48, 42), R.brown[3])
c:fillMask(c:rect(43, 11, 44, 12), R.paper[4]) c:fillMask(c:rect(45, 8, 47, 10), R.paper[3])
c:px(47, 4, R.petal[4]) c:px(49, 4, R.petal[4]) c:fillMask(c:rect(47, 5, 49, 6), R.petal[4]) c:px(48, 7, R.petal[4])
D.fin()
