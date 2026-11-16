-- Teal Ferry (sp-teal-ferry), yard sprite 64x64. Haiku pass, c06.
-- Uncommon, thornblade. A teal-coated pal standing in a flat ferry boat with a flower aboard,
-- one hand raised in a wave.
-- quirk: a gold fish pops up beside the boat to wave back.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-teal-ferry-yard", 64)

-- river water along the bottom
local water = c:rect(0, 52, 63, 63)
c:part(water, "sea", { noshade = true })
H.dots(c, { { 6, 57 }, { 7, 57 }, { 16, 60 }, { 17, 60 }, { 44, 58 }, { 45, 58 } }, P.sea.hi)

-- quirk: a gold fish waving from the water
local fish = c:ellipse(53, 56, 3, 2)
c:part(fish, "gold", { band = 1 })
H.dot(c, 55, 55, P.ink)
H.dot(c, 57, 56, P.gold.deep)

-- boat hull and seat
local hull = c:poly{ { 8, 44 }, { 56, 44 }, { 50, 52 }, { 14, 52 } }
c:part(hull, "wood", { band = 2, pop = { x = 14, y = 46, horizontal = true } })
c:part(c:rect(14, 45, 50, 45), "wood", { noshade = true })

-- flower aboard
local flower = c:ellipse(44, 39, 4, 4)
c:part(flower, "petal", { band = 1 })
H.dot(c, 44, 39, P.gold.base)

-- body
local body = c:ellipse(29, 33, 14, 13)
c:part(body, "sea", { pop = { x = 21, y = 26, horizontal = true } })

-- raised waving arm and hand
c:part(c:line({ { 40, 34 }, { 47, 28 }, { 49, 20 } }, 2.4), "sea", { band = 1 })
c:part(c:ellipse(49, 18, 2, 2), "skinA", { band = 1 })
H.dots(c, { { 54, 14 }, { 56, 18 } }, P.cream)

-- face
c:eyeLocked(23, 29)
c:eyeLocked(34, 29)
c:cheek(20, 35)
c:cheek(36, 35)
H.dots(c, { { 28, 36 }, { 29, 37 }, { 30, 37 }, { 31, 36 } }, P.ink)

H.done(c, "sp-teal-ferry-yard")
