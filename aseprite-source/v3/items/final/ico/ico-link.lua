local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-link: two interlocked steel chain links. quirk: a patch of orange rust and a moss tuft on the lower link.
local c = D.new("ico-link")
local function ring(x0, y0, x1, y1) return c:rrect(x0, y0, x1, y1, 9), c:rrect(x0 + 6, y0 + 6, x1 - 6, y1 - 6, 4) end
local a, ai = ring(6, 10, 40, 38)
local b, bi = ring(24, 26, 58, 54)
local A, B = D.sub(a, ai), D.sub(b, bi)
D.lit(A, D.STEEL, 3)
D.lit(B, D.STEEL, 3)
-- re-lay A over B at the upper-left crossing, B stays over A at the lower-right
local ov = D.isect(A, c:rect(24, 26, 32, 33))
D.lit(A, D.STEEL, 3)
D.lit(D.isect(B, c:rect(33, 33, 40, 38)), D.STEEL, 2)
D.seam(c, D.isect(B, c:rect(33, 33, 40, 38)), A, D.STEEL[1])
for _, p in ipairs{{50,46},{51,46},{51,47},{52,48},{49,47}} do D.px(p[1], p[2], D.ORG[3]) end
D.px(50, 46, D.ORG[5])
for _, p in ipairs{{40,53},{41,52},{42,53}} do D.px(p[1], p[2], D.GREEN[4]) end
D.fin()
