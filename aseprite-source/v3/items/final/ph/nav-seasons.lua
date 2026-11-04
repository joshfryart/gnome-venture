-- nav-seasons (dC25 first draft, Sonnet). A golden sun with short rays peeks behind a fluffy cloud. quirk: a red leaf and a pale snowflake drift off the cloud together, one season each.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-seasons") local B, R, HP = D.B, D.R, D.HP
for i = 0, 7 do local a = i * math.pi / 4 + .2
  B.lit(c, c:line({{23 + math.cos(a) * 11, 23 + math.sin(a) * 11}, {23 + math.cos(a) * 18, 23 + math.sin(a) * 18}}, 3), R.sun, 1.5) end
B.lit(c, c:ellipse(23, 23, 11, 11), R.sun, 6)
local cl = c:ellipse(34, 44, 12, 9):add(c:ellipse(46, 46, 10, 8)):add(c:ellipse(22, 48, 10, 7)):add(c:rect(14, 48, 54, 55))
B.lit(c, cl, R.sky, 6)
B.lit(c, B.ell(55, 33, 3, 1.7, .8), R.red, 1.2) 
c:px(8, 40, R.sky[6]) c:px(7, 41, R.sky[6]) c:px(9, 41, R.sky[6]) c:px(8, 42, R.sky[6]) c:px(8, 41, R.sky[4])
D.fin()
