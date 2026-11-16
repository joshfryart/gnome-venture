-- Petal Pinch (br-petal-pinch), yard sprite 64x64. Haiku pass, c06.
-- Common, bloomcaller. A round pink pal with a wooden pocket full of petals and one petal held up.
-- quirk: a petal is still falling from its fingers at the top left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-petal-pinch-yard", 64)

-- body
local body = c:ellipse(32, 38, 18, 17)
c:part(body, "petal", { pop = { x = 21, y = 28, horizontal = true } })

-- the petal held up in one hand
local held = c:poly{ { 46, 21 }, { 53, 14 }, { 55, 19 }, { 49, 24 } }
c:part(held, "petal", { band = 1, pop = { x = 49, y = 18, horizontal = false } })
c:part(c:ellipse(47, 25, 2, 2), "skinA", { band = 1 })

-- falling petal (quirk)
c:part(c:poly{ { 8, 12 }, { 11, 9 }, { 13, 13 }, { 10, 16 } }, "petal", { band = 1 })

-- wooden pocket on the belly with petals tucked in it
local pocket = c:rrect(22, 44, 42, 53, 3)
c:part(pocket, "wood", { pop = { x = 25, y = 46, horizontal = true } })
c:part(c:poly{ { 25, 44 }, { 28, 40 }, { 31, 44 } }, "petal", { band = 1 })
c:part(c:poly{ { 33, 44 }, { 36, 39 }, { 39, 44 } }, "petal", { band = 1 })

-- face
c:eyeLocked(22, 30)
c:eyeLocked(37, 30)
H.dots(c, { { 30, 37 }, { 31, 38 }, { 32, 38 }, { 33, 37 } }, P.ink)

-- feet
c:part(c:ellipse(23, 56, 4, 2), "petal", { band = 1 })
c:part(c:ellipse(41, 56, 4, 2), "petal", { band = 1 })

H.done(c, "br-petal-pinch-yard")
