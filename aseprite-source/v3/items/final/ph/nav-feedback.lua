-- nav-feedback (dC25 first draft, Sonnet). Blue speech bubble with three chat dots and a tail. quirk: a small heart pops out of the top corner.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-feedback") local B, R, HP = D.B, D.R, D.HP
B.lit(c, c:poly{{14, 40}, {10, 58}, {28, 42}}, R.blue, 2)
B.lit(c, c:rrect(7, 10, 53, 46, 11), R.blue, 6)
D.line(c, {{14, 12}, {46, 12}}, 1, R.blue[6])
for i = 0, 2 do B.lit(c, c:ellipse(19.5 + i * 11, 28, 3.5, 3.5), R.cream, 2) end
-- heart
c:fillMask(c:poly{{52, 7}, {58, 7}, {58, 11}, {55, 15}, {52, 11}}, R.red[4])
c:fillMask(c:rect(50, 6, 52, 9), R.red[4]) c:px(53, 8, R.red[6])
D.fin()
