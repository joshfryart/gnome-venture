-- Panda Puff (br-panda-puff), yard sprite 64x64. Haiku pass, c06.
-- Common, brewroot. A fluffy round panda pal with dark ear and eye patches, hugging a bamboo stalk.
-- quirk: the bamboo stalk has one bite taken out of its top end.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-panda-puff-yard", 64)

-- bamboo stalk (drawn first, the body sits in front of it)
local stalk = c:line({ { 52, 58 }, { 56, 40 }, { 56, 18 }, { 57, 8 } }, 2)
stalk:cut(c:rect(55, 6, 60, 9))
c:part(stalk, "moss", { band = 1, pop = { x = 55, y = 30, horizontal = false } })
c:part(c:rect(53, 26, 58, 26), "moss", { noshade = true })
c:part(c:rect(53, 44, 58, 44), "moss", { noshade = true })

-- fluffy body: a round mass with tufts round the edge
local fluff = c:ellipse(30, 36, 18, 18)
for _, p in ipairs({ { 14, 24 }, { 46, 24 }, { 12, 40 }, { 48, 42 }, { 30, 54 }, { 20, 50 }, { 40, 52 } }) do
  fluff:add(c:ellipse(p[1], p[2], 4, 4))
end
c:part(fluff, "skinA", { pop = { x = 20, y = 24, horizontal = true } })

-- dark ears
H.flat(c, c:ellipse(18, 20, 5, 5), P.stone.deep)
H.flat(c, c:ellipse(42, 20, 5, 5), P.stone.deep)

-- dark eye patches
H.flat(c, c:ellipse(23, 33, 5, 4), P.stone.deep)
H.flat(c, c:ellipse(37, 33, 5, 4), P.stone.deep)

-- face
c:eyeLocked(21, 31)
c:eyeLocked(36, 31)
H.dots(c, { { 29, 40 }, { 30, 40 }, { 31, 40 }, { 32, 40 } }, P.ink)
H.dots(c, { { 30, 42 }, { 32, 42 } }, P.ink)
H.dot(c, 30, 40, P.cream)

-- paws holding the stalk
c:part(c:ellipse(49, 40, 3, 3), "skinA", { band = 1 })
c:part(c:ellipse(46, 48, 3, 3), "skinA", { band = 1 })

-- feet
H.flat(c, c:ellipse(22, 56, 4, 2), P.stone.deep)
H.flat(c, c:ellipse(38, 56, 4, 2), P.stone.deep)

H.done(c, "br-panda-puff-yard")
