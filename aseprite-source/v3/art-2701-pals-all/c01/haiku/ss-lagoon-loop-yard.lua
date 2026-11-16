-- Lagoon Loop (ss-lagoon-loop), yard 64x64. Haiku first pass, c01. Seedkeeper, uncommon, Sunsprinkle.
-- A sand-gold ring standing on its edge with a sea-blue lagoon in the hole.
-- quirk: the lagoon winks (sparkle in the hole) and the right eye is a wink, not a disc.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("ss-lagoon-loop-yard", 64)
local P = H.P

c:groundShadow(32, 58, 20, 3)

local outer = c:ellipse(32, 36, 22, 20)
local hole = c:ellipse(32, 33, 10, 8)
local ring = outer:copy():cut(hole)

c:part(ring, "gold", { band = 3 })
-- the lagoon in the hole: sea ramp with a sky glint
c:part(hole, "sea", { band = 2, pop = { x = 27, y = 28, horizontal = true } })
c:sparkle(36, 30)
c:px(28, 36, P.sky.hi) c:px(29, 36, P.sky.hi)

-- a little trim line round the ring
c:stitch({ { 12, 44 }, { 20, 52 }, { 32, 56 }, { 44, 52 }, { 52, 44 } })

-- face on the lower band
c:eyeLocked(18, 45)
-- the right eye winks: a closed arc
c:px(38, 48, P.ink) c:px(39, 47, P.ink) c:px(40, 47, P.ink) c:px(41, 48, P.ink)
c:cheek(14, 52) c:cheek(46, 52)
for x = 28, 33 do c:px(x, 50, P.ink) end
c:px(27, 49, P.ink) c:px(34, 49, P.ink)

H.done(c, "ss-lagoon-loop-yard")
