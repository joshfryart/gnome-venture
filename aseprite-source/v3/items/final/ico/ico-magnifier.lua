local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-magnifier: wooden handle, brass ring and a pale glass lens. quirk: the lens magnifies a big ladybird.
local c = D.new("ico-magnifier")
D.lit(D.seg({{40,40},{54,54}}, 7), "wood", 2.5)
D.lit(D.seg({{37,37},{42,42}}, 6), D.GOLD, 1)
local ring = D.ring(26, 26, 20, 15) D.lit(ring, D.GOLD, 3)
D.lit(D.ell(26, 26, 15, 15), "sea", 7, {})
D.fill(D.ell(26, 26, 14, 14), "#d4f2f8")
D.fill(D.ell(26, 26, 14, 14):cut(D.ell(30, 30, 12, 12)), "#e8f8fb")
D.lit(D.ell(26, 28, 7, 8), D.RED, 3)
D.fill(c:rect(26, 22, 26, 36), D.RED[1])
D.fill(D.ell(23, 27, 1.5, 1.5), D.RED[1]) D.fill(D.ell(29, 30, 1.5, 1.5), D.RED[1])
D.fill(D.ell(26, 20, 3, 2), INK)
for _, p in ipairs{{14,18},{15,16},{17,14}} do D.px(p[1], p[2], CR) end
D.fin()
