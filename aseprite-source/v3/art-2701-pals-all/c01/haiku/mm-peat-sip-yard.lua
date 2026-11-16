-- Peat Sip (mm-peat-sip), yard 64x64. Haiku first pass, c01. Brewroot, common, Mistmoor.
-- A rounded peat-brown mound with a moss top, a stone chimney and a teacup held in front.
-- quirk: the chimney puffs three smoke clouds; a stray curl of steam from the cup.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("mm-peat-sip-yard", 64)
local P = H.P

c:groundShadow(32, 59, 20, 3)

-- chimney (behind the dome)
c:part(c:rect(38, 18, 44, 28), "stone", { band = 2 })
c:fillMask(c:rect(37, 17, 45, 18), P.stone.deep)

-- smoke puffs
c:part(c:ellipse(46, 12, 4, 3), "sky", { band = 2 })
c:part(c:ellipse(52, 7, 3, 2), "sky", { band = 1 })
c:part(c:ellipse(41, 6, 2, 2), "sky", { band = 1 })

-- peat dome
local dome = c:ellipse(30, 40, 20, 16)
c:part(dome, "wood", { band = 3 })
-- moss cap along the top
local cap = dome:copy():clip(c:rect(0, 0, 63, 33))
c:part(cap, "moss", { band = 2 })
-- peat fibres
c:px(14, 42, P.wood.shade) c:px(20, 47, P.wood.shade) c:px(40, 46, P.wood.shade)

-- face
c:eyeLocked(20, 39)
c:eyeLocked(32, 39)
c:cheek(17, 46) c:cheek(36, 46)
for x = 25, 29 do c:px(x, 48, P.ink) end
c:px(24, 47, P.ink) c:px(30, 47, P.ink)

-- teacup held out front
c:part(c:rrect(46, 44, 54, 53, 2), "sky", { band = 2 })
c:part(c:rect(44, 45, 47, 46), "sky", { noshade = true })
c:fillMask(c:rect(47, 49, 50, 50), P.sky.deep)
c:px(50, 47, P.sky.hi)
-- steam curl
c:px(49, 40, P.sky.base) c:px(50, 39, P.sky.base) c:px(49, 38, P.sky.base) c:px(48, 37, P.sky.base)

H.done(c, "mm-peat-sip-yard")
