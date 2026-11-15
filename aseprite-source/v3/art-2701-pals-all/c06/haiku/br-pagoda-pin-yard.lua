-- Pagoda Pin (br-pagoda-pin), yard sprite 64x64. Haiku pass, c06.
-- Uncommon, rootwarden. A tiered pagoda pal with a gold spire, ember roofs and a wood-panel face.
-- quirk: one arm sticks out and points straight up at the spire top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-pagoda-pin-yard", 64)

-- base platform
c:part(c:rrect(8, 50, 56, 60, 2), "stone", { band = 2 })

-- lowest tier (wood wall with a dark door)
c:part(c:rect(14, 42, 50, 50), "wood", { pop = { x = 17, y = 43, horizontal = true } })
c:part(c:rect(28, 46, 36, 50), "wood", { band = 1, noshade = true })
H.flat(c, c:rect(29, 47, 35, 50), P.wood.deep)

-- lower roof
c:part(c:poly{ { 12, 42 }, { 52, 42 }, { 58, 48 }, { 6, 48 } }, "ember", { band = 1, pop = { x = 16, y = 43, horizontal = true } })

-- middle tier wall with the face
c:part(c:rect(19, 30, 45, 40), "wood", { pop = { x = 22, y = 31, horizontal = true } })
c:eyeLocked(22, 33)
c:eyeLocked(36, 33)
H.dots(c, { { 30, 37 }, { 31, 38 }, { 32, 38 }, { 33, 37 } }, P.ink)

-- middle roof
c:part(c:poly{ { 18, 30 }, { 46, 30 }, { 53, 36 }, { 11, 36 } }, "ember", { band = 1, pop = { x = 21, y = 31, horizontal = true } })

-- upper tier wall
c:part(c:rect(24, 18, 40, 24), "wood", { pop = { x = 26, y = 19, horizontal = true } })

-- top roof
c:part(c:poly{ { 22, 18 }, { 42, 18 }, { 50, 24 }, { 14, 24 } }, "ember", { band = 1, pop = { x = 24, y = 19, horizontal = true } })

-- gold spire on top
c:part(c:poly{ { 30, 14 }, { 34, 14 }, { 33, 8 }, { 31, 8 } }, "gold", { band = 1 })
c:part(c:ellipse(32, 6, 2, 2), "gold", { band = 1 })
H.dot(c, 31, 5, P.gold.hi)

-- arm pointing up, from the side of the middle tier
c:part(c:line({ { 44, 37 }, { 50, 32 }, { 53, 24 }, { 54, 15 } }, 2.2), "skinA", { band = 1 })
c:part(c:ellipse(54, 13, 2, 2), "skinA", { band = 1 })
H.dots(c, { { 58, 10 }, { 58, 14 } }, P.cream)

H.done(c, "br-pagoda-pin-yard")
