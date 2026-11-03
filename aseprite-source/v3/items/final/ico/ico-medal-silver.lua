local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-medal-silver: round silver disc with a bold 2, blue ribbon. quirk: its ribbon end is twisted into a little curl.
local c = D.new("ico-medal-silver")
D.lit(c:poly{{20,4},{32,4},{34,28},{28,34}}, D.BLUE, 1.5)
D.lit(c:poly{{44,4},{32,4},{30,28},{38,34}}, "sea", 1.5)
D.lit(D.seg({{26,32},{20,38},{14,36},{14,32}}, 3), D.BLUE, 1)
local disc = D.disc(32, 44, 15)
D.lit(disc, D.SILV, 7)
D.fill(D.ring(32, 44, 12, 11), D.SILV[2])
D.fill(c:rect(27, 36, 37, 38), D.SILV[6]) D.fill(c:rect(35, 36, 37, 43), D.SILV[6]) D.fill(c:rect(27, 41, 37, 43), D.SILV[6]) D.fill(c:rect(27, 43, 29, 50), D.SILV[6]) D.fill(c:rect(27, 48, 37, 50), D.SILV[6])
D.fill(c:rect(27, 50, 37, 50), D.SILV[1])
D.px(22, 36, D.CR) D.px(23, 35, D.CR)
D.fin()
