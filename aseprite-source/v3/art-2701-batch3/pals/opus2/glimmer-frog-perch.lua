-- Glimmer Frog (rr-glimmer-frog), perch sprite 36x36. Opus second pass, hand-built at this size:
-- wide head with two eye domes holding 2x3 pill eyes, a bold ink grin, folded hind legs, pale belly,
-- three single-pixel glow spots.
-- quirk: the glowing gold throat sac, puffed mid-croak.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("glimmer-frog-perch", 36)

local FROG = { "#173a38", "#1f5a46", "#2b8450", "#47ab58", "#7fcd66", "#bce88c" }
local BELY = { "#9cc283", "#c4dea0", "#e2f0bf" }
local GLOW = { "#c98322", "#f5b82e", "#ffe38a", "#fff4c8" }

c:groundShadow(18, 32, 14, 1.5)

-- hind legs + feet
for _, s in ipairs({ { 8, -1 }, { 28, 1 } }) do
  O.shade(c, c:ellipse(s[1], 26, 4, 3.5), FROG, { sphere = { s[1] - 1, 24, 5 }, amb = .2, wrap = .35 })
  O.flat(c, c:rect(s[1] - 3 + s[2] * 2, 30, s[1] + 2 + s[2] * 2, 30), FROG[3], "foot")
  O.dot(c, s[1] + s[2] * 4, 30, FROG[6])
end
-- body + belly
O.shade(c, c:ellipse(18, 25, 8.5, 6), FROG, { sphere = { 15, 21, 10 }, amb = .2, wrap = .35, sep = FROG[1] })
local bel = c:ellipse(18, 27.5, 5, 3)
O.shade(c, bel, BELY, { R = 2, amb = .4, cuts = { .4, .75 } })
-- head + domes
local hd = c:ellipse(18, 18, 10, 5)
hd:add(c:ellipse(12, 13.5, 3.5, 3.5)):add(c:ellipse(24, 13.5, 3.5, 3.5))
O.shade(c, hd, FROG, { sphere = { 14, 13, 12 }, amb = .22, wrap = .35 })
-- quirk: glowing throat sac
local sac = c:ellipse(18, 22.5, 4, 2.5)
O.shade(c, sac, GLOW, { sphere = { 17, 21, 4 }, amb = .45, wrap = .5, cuts = { .3, .55, .8 } })
-- front feet
O.flat(c, c:rect(12, 29, 14, 30), FROG[4], "arm") O.dot(c, 12, 30, FROG[6])
O.flat(c, c:rect(22, 29, 24, 30), FROG[3], "arm") O.dot(c, 24, 30, FROG[5])
-- glow spots
O.dots(c, { { 18, 13 }, { 6, 24 }, { 30, 24 } }, GLOW[3])

-- face
c:eyeSmall(11, 12)
c:eyeSmall(24, 12)
O.dot(c, 11, 17, "#f5809f") O.dot(c, 25, 17, "#f5809f")
O.dots(c, { { 16, 16 }, { 20, 16 } }, FROG[1])
O.dots(c, { { 8, 17 }, { 9, 18 }, { 10, 19 }, { 11, 19 }, { 12, 19 }, { 13, 19 }, { 14, 19 }, { 15, 19 }, { 16, 19 }, { 17, 19 },
            { 18, 19 }, { 19, 19 }, { 20, 19 }, { 21, 19 }, { 22, 19 }, { 23, 19 }, { 24, 19 }, { 25, 19 }, { 26, 19 }, { 27, 18 }, { 28, 17 } }, P.ink)

O.shift(c, 0, -3)
O.done(c, "glimmer-frog-perch")
