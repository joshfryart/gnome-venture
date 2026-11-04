-- nav-tasks (dC25 first draft, Sonnet). Brown clipboard with a gold clip and a paper sheet of three tick boxes. quirk: the last box is still empty and a pencil lies across the corner.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-tasks") local B, R, HP = D.B, D.R, D.HP
B.lit(c, c:rrect(11, 8, 53, 58, 4), "wood", 5)
B.lit(c, c:rect(16, 14, 48, 53), R.paper, 2)
B.lit(c, c:rrect(24, 4, 40, 12, 2), R.gold, 2) c:fillMask(c:rect(29, 7, 35, 8), R.gold[1])
for i = 0, 2 do
  local y = 19 + i * 11
  c:fillMask(c:rect(19, y, 25, y + 6), R.sky[3]) c:fillMask(c:rect(20, y + 1, 24, y + 5), R.cream[6])
  if i < 2 then B.ln(c, 20, y + 3, 22, y + 5, R.leaf[4]) B.ln(c, 22, y + 5, 25, y - 1, R.leaf[4]) B.ln(c, 21, y + 3, 22, y + 4, R.leaf[4]) end
  D.line(c, {{29, y + 3}, {45, y + 3}}, 2, R.brown[3])
end
D.rod(c, {{44, 60}, {58, 40}}, 3, R.sun, 1.5) c:fillMask(c:rect(42, 59, 44, 61), R.petal[4])
D.fin()
