-- Koi Kin (br-koi-kin), yard sprite 64x64. Haiku pass, c06.
-- Common, seedkeeper. An orange koi pal with a gold patch, fins and a tail, in a pond.
-- quirk: two smaller orange cousins swim behind it in the pond.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-koi-kin-yard", 64)

-- pond water along the bottom
local pond = c:rect(0, 50, 63, 63)
c:part(pond, "sea", { noshade = true })
H.dots(c, { { 8, 55 }, { 9, 55 }, { 50, 58 }, { 51, 58 } }, P.sea.hi)

-- quirk: two smaller cousins behind
c:part(c:ellipse(10, 58, 3, 2), "ember", { band = 1 })
c:part(c:ellipse(54, 54, 3, 2), "ember", { band = 1 })

-- tail fin
local tail = c:poly{ { 13, 34 }, { 3, 24 }, { 5, 35 }, { 3, 46 } }
c:part(tail, "ember", { band = 1, pop = { x = 8, y = 31, horizontal = false } })

-- body
local body = c:ellipse(34, 35, 20, 12)
c:part(body, "ember", { pop = { x = 24, y = 27, horizontal = true } })

-- gold patch on the back
c:part(c:ellipse(40, 28, 5, 3), "gold", { band = 1 })

-- dorsal and pectoral fins
c:part(c:poly{ { 26, 24 }, { 33, 14 }, { 40, 24 } }, "petal", { band = 1 })
c:part(c:poly{ { 32, 42 }, { 39, 48 }, { 30, 47 } }, "gold", { band = 1 })

-- face on the front of the fish
c:eyeLocked(44, 30)
H.dots(c, { { 52, 36 }, { 53, 37 }, { 53, 35 } }, P.ink)

-- bubble (sea-blue)
H.dots(c, { { 56, 20 }, { 58, 16 } }, P.sky.hi)

H.done(c, "br-koi-kin-yard")
