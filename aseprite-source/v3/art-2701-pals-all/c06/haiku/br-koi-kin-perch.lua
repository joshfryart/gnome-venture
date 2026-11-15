-- Koi Kin (br-koi-kin), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: an orange koi with a gold patch, tail and dorsal fin, over pond water. Common, seedkeeper.
-- quirk: a smaller orange cousin in the pond.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-koi-kin-perch", 36)

c:part(c:rect(0, 28, 35, 35), "sea", { noshade = true })
c:part(c:ellipse(7, 31, 2, 1), "ember", { band = 1 })

c:part(c:poly{ { 7, 19 }, { 1, 13 }, { 2, 25 } }, "ember", { band = 1 })
c:part(c:ellipse(19, 19, 11, 7), "ember", { pop = { x = 12, y = 14, horizontal = true } })
c:part(c:poly{ { 13, 14 }, { 18, 8 }, { 23, 14 } }, "petal", { band = 1 })
c:part(c:ellipse(22, 15, 2, 1), "gold", { band = 1 })

c:eyeSmall(24, 17)
H.dot(c, 29, 20, P.ink)
H.done(c, "br-koi-kin-perch")
