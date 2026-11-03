local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-medal-gold: spiky sunburst gold medal with a star and red ribbon. quirk: someone has taken a tooth-mark bite out of the edge.
local c = D.new("ico-medal-gold")
D.lit(c:poly{{18,4},{30,4},{34,30},{26,36}}, D.RED, 1.5)
D.lit(c:poly{{46,4},{34,4},{30,30},{38,36}}, D.RED, 1.5)
local bur = D.disc(32, 44, 14)
for i = 0, 11 do local a = i * math.pi / 6 bur:add(D.ell(32 + math.cos(a) * 13, 44 + math.sin(a) * 13, 3, 3)) end
bur:cut(D.ell(44, 54, 3, 3)):cut(D.ell(46, 51, 2, 2))
D.lit(bur, D.GOLD, 6)
D.fill(D.ring(32, 44, 11, 10), D.GOLD[2])
D.lit(c:poly{{32,35},{35,41},{42,42},{37,47},{38,54},{32,50},{26,54},{27,47},{22,42},{29,41}}, D.GOLD, 2)
D.fill(D.ell(32, 45, 1.6, 1.6), D.GOLD[6])
c:sparkle(50, 28)
D.fin()
