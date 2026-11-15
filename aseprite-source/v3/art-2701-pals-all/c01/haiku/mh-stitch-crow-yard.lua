-- Stitch Crow (mh-stitch-crow), yard 64x64. Haiku pass, c01.
-- thornblade, uncommon. A crow in a straw scarecrow hat, stitched wing, gold beak, long legs.
-- quirk: a very serious hat, held on with a stitched band.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-stitch-crow-yard", 64)

local CROW = { "#2a2440", "#3a3058", "#4e4272", "#66588c", "#8a78b0", "#b4a4d4" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982", "#f3d2a0", "#f8e4c0" }
local BEAK = { "#8f4a1f", "#b5652a", "#d98322", "#f5b82e", "#ffd55a", "#ffe9a0" }
local INK  = P.ink

c:groundShadow(31, 58, 14, 3)

-- legs
O.flat(c, c:line({ {28,48}, {26,57} }, 1), BEAK[2])
O.flat(c, c:line({ {34,48}, {36,57} }, 1), BEAK[2])

-- tail (behind body)
O.shade(c, c:poly{ {22,40},{8,50},{10,58},{24,50} }, CROW, { R = 3 })

-- body and head
O.shade(c, c:ellipse(30, 38, 13, 11), CROW, { R = 6, sep = CROW[1] })
O.shade(c, c:ellipse(34, 22, 9, 8), CROW, { R = 5, sep = CROW[1] })

-- stitched wing
local wing = c:poly{ {22,36},{34,30},{42,38},{34,46},{24,46} }
O.shade(c, wing, CROW, { R = 3, sep = CROW[1] })
c:stitch({ {22,38}, {30,34}, {40,38} })

-- beak with a nostril
O.shade(c, c:poly{ {42,20},{50,23},{42,26} }, BEAK, { R = 1, sep = BEAK[1] })
O.dot(c, 43, 22, INK)

-- scarecrow hat: crown, brim, dark band, stitched top
O.shade(c, c:rrect(26, 3, 42, 12, 2), WOOD, { R = 2 })
O.shade(c, c:ellipse(34, 13, 14, 3), WOOD, { R = 2, sep = WOOD[1] })
local band = {}
for x = 27, 41 do band[#band + 1] = { x, 10 } end
O.dots(c, band, WOOD[1])
c:stitch({ {27,7}, {41,7} })

-- serious brows, locked eyes
O.dots(c, { {29,18},{30,18},{31,18} }, INK)
O.dots(c, { {36,18},{37,18},{38,18} }, INK)
c:eyeLocked(29, 20)
c:eyeLocked(36, 20)

O.done(c, "mh-stitch-crow-yard")
