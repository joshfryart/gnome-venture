local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-log: horizontal bark log with pale end grain rings. quirk: a sapling sprouts from a knot with two tiny leaves.
local c = D.new("ico-log")
local body = c:rect(8, 28, 46, 54)
D.cyl(D.isect(body, c:rect(8, 28, 46, 54)), D.BARK, 8, 46, {})
for _, p in ipairs{{14,32,22,32},{12,40,26,40},{28,34,40,34},{18,47,36,47},{30,50,42,50}} do D.ln(p[1], p[2], p[3], p[4], D.BARK[2]) end
for _, p in ipairs{{10,30,16,30},{24,38,34,38},{34,44,44,44}} do D.ln(p[1], p[2], p[3], p[4], D.BARK[5]) end
local face = D.ell(46, 41, 8, 13)
D.lit(face, D.SAND, 5)
D.fill(D.ring(46, 41, 6, 5), D.SAND[2]) D.fill(D.ring(46, 41, 3, 2), D.SAND[2]) D.px(46, 41, D.SAND[1])
D.lit(D.ell(24, 36, 3, 2), D.BARK, 1) D.px(24, 36, D.BARK[1])
D.ln(24, 33, 24, 24, D.GREEN[3]) D.ln(25, 33, 25, 24, D.GREEN[3])
D.leaf(25, 25, 34, 18, 3, "moss", {3}) D.leaf(24, 28, 15, 20, 3, "moss", {3})
D.fin()
