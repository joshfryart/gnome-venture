local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-info: bold blue disc with a cream "i" and a little speech tail. quirk: the dot of the i is a tiny gold lightbulb-spark.
local c = D.new("ico-info")
local disc = D.ell(32, 30, 22, 22):add(c:poly{{14,44},{24,48},{14,56}})
D.lit(disc, D.BLUE, 6)
D.radial(D.ring(32, 30, 20, 19), 32, 30, 0, 99, D.BLUE[5])
local dot = D.ell(32, 17, 3.4, 3.4) D.lit(dot, D.GOLD, 2)
D.lit(c:rrect(28, 26, 36, 45, 2), D.CREAM, 3)
D.lit(c:rect(25, 43, 39, 46), D.CREAM, 1)
D.px(29, 26, CR) D.px(29, 27, CR)
c:sparkle(41, 12)
D.fin()
