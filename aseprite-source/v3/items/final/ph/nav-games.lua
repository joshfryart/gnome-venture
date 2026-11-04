-- nav-games (dC25 first draft, Sonnet). A fat cream die showing five red pips, with a pointed gnome-hat shaped centre pip. quirk: the centre pip is a tiny red hat; one corner is chipped.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-games") local B, R, HP = D.B, D.R, D.HP
D.shadow(c, 32, 57, 21, 2)
B.lit(c, c:rrect(9, 8, 55, 54, 10), R.paper, 7)
c:fillMask(c:rect(52, 6, 56, 14), R.cream[1])
for _, p in ipairs{{20, 19}, {44, 19}, {20, 43}, {44, 43}} do B.lit(c, c:ellipse(p[1], p[2], 4.5, 4.5), R.red, 2.5) end
B.lit(c, c:poly{{27, 38}, {37, 38}, {32, 24}}, R.red, 3) c:px(31, 28, R.cream[6])
c:sparkle(14, 12)
D.fin()
