-- nav-crafting (dC25 first draft, Sonnet). Chunky claw hammer on a diagonal wooden handle. quirk: a bent nail is stuck in the handle and a gold spark flies off the head.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-crafting") local B, R, HP = D.B, D.R, D.HP
D.rod(c, {{12, 54}, {42, 24}}, 5, "wood", 2.5)
D.line(c, {{15, 52}, {40, 27}}, 1, R.brown[5])
B.lit(c, c:line({{34, 12}, {52, 30}}, 9), "stone", 4)
B.lit(c, c:poly{{32, 12}, {22, 12}, {28, 18}, {34, 20}}, "stone", 2)
D.line(c, {{36, 13}, {48, 25}}, 1, R.iron[6])
B.ln(c, 16, 44, 10, 44, R.iron[4]) B.ln(c, 10, 44, 10, 40, R.iron[4]) c:px(16, 44, R.iron[6])
c:sparkle(55, 10)
D.fin()
