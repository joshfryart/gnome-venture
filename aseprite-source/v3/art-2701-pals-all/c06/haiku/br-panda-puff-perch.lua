-- Panda Puff (br-panda-puff), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: a white fluffy round pal with dark ears and eye patches and a bamboo stalk. Common, brewroot.
-- quirk: the stalk is bitten at the top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-panda-puff-perch", 36)

c:part(c:line({ { 30, 34 }, { 31, 22 }, { 31, 8 } }, 2), "moss", { band = 1 })
c:part(c:rect(29, 12, 33, 13), "moss", { noshade = true })
c:part(c:rect(30, 5, 32, 7), "moss", { noshade = true })
H.flat(c, c:rect(30, 6, 31, 6), P.moss.deep)

local fluff = c:ellipse(18, 21, 10, 10)
fluff:add(c:ellipse(10, 15, 3, 3))
fluff:add(c:ellipse(26, 15, 3, 3))
fluff:add(c:ellipse(18, 31, 3, 3))
c:part(fluff, "skinA", { pop = { x = 12, y = 14, horizontal = true } })

H.flat(c, c:ellipse(10, 12, 3, 3), P.stone.deep)
H.flat(c, c:ellipse(26, 12, 3, 3), P.stone.deep)
H.flat(c, c:ellipse(13, 18, 3, 3), P.stone.deep)
H.flat(c, c:ellipse(23, 18, 3, 3), P.stone.deep)

c:eyeSmall(12, 17)
c:eyeSmall(22, 17)
H.dots(c, { { 17, 22 }, { 18, 22 } }, P.ink)
H.done(c, "br-panda-puff-perch")
