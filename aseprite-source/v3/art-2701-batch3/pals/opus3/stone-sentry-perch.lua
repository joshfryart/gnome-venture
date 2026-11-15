-- Stone Sentry (mm-stone-sentry), perch sprite 36x36. Opus richness pass (opus3), hand-built at this size;
-- adds sparse granite flecks, a rim light and cool bounce, lit moss tips and the drop on its nose:
-- the face fills the stone (brow ledge, pill eyes, 2x3 pebble nose, straight ink mouth) so it reads at 36 px;
-- moss mantle cut to one band with two drips, one lichen spot.
-- quirk: the little drizzle cloud over its right shoulder.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("stone-sentry-perch", 36)

local STN  = { "#33344a", "#4d4f67", "#6b6d86", "#8d8fa5", "#b0b1c2", "#d2d2dc" }
local MOSS = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070", "#cfe896" }
local CLD  = { "#5d6b8c", "#8696b4", "#b2c0d6", "#d9e3ee" }
local DROP = { "#3a86b0", "#5fc4c8", "#b6f0e0" }

c:groundShadow(17, 32, 11, 1.5)
for _, fx in ipairs({ 13, 22 }) do O.shade(c, c:ellipse(fx, 31, 3, 1.2), STN, { R = 1, amb = .25 }) end
for _, ax in ipairs({ 6.5, 28.5 }) do O.shade(c, c:ellipse(ax, 22, 1.5, 3.5), STN, { R = 1, amb = .3 }) end

local body = c:poly{ { 10, 10 }, { 15, 9 }, { 21, 9 }, { 25, 11 }, { 27, 16 }, { 27, 27 }, { 25, 30 }, { 10, 30 }, { 8, 27 }, { 8, 15 } }
local bb = {}
body:each(function(x, y) if y > 28 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, STN, { R = 4, bias = bb, amb = .2, wrap = .35, rim = true, bounce = "#6f7ea0", bmax = 2 })
O.tex(c, bI, bT, STN, function(x, y, i) if H(x, y, 17) > .93 and i >= 2 and i <= 5 and y > 15 then return 1 end end)
O.mark(c, { { 11, 24 }, { 12, 25 }, { 12, 26 } }, STN[2]) -- crack
O.mark(c, { { 23, 26 }, { 24, 26 }, { 23, 27 } }, "#c4c88e") -- lichen

-- moss mantle
local moss = c:ellipse(17.5, 10.5, 9, 2.5)
moss:add(c:rect(10, 12, 11, 13)) moss:add(c:rect(23, 12, 24, 14))
O.shade(c, moss, MOSS, { R = 2, amb = .25, wrap = .4, sep = MOSS[1], rim = true })
O.dots(c, { { 13, 7 }, { 19, 7 } }, MOSS[5])

-- face
for _, ex in ipairs({ 12, 21 }) do
  O.mark(c, { { ex - 1, 14 }, { ex, 14 }, { ex + 1, 14 }, { ex + 2, 14 } }, STN[2])
  O.mark(c, { { ex - 1, 13 }, { ex, 13 }, { ex + 1, 13 }, { ex + 2, 13 } }, STN[6])
  c:eyeSmall(ex, 15)
end
O.flat(c, c:rect(16, 17, 18, 19), STN[4], "nose")
O.dots(c, { { 16, 17 }, { 17, 17 } }, STN[6]) O.dots(c, { { 16, 20 }, { 17, 20 }, { 18, 20 } }, STN[2]) O.dot(c, 18, 19, STN[3])
O.dot(c, 18, 18, DROP[3]) -- the drop on its nose
O.dot(c, 10, 19, "#f5809f") O.dot(c, 25, 19, "#f5809f")
O.dots(c, { { 14, 22 }, { 15, 22 }, { 16, 22 }, { 17, 22 }, { 18, 22 }, { 19, 22 }, { 20, 22 } }, P.ink)

-- quirk: drizzle cloud
local cl = O.unionCircles{ { 26, 5, 2, 1.5 }, { 29, 4, 2.5, 2 }, { 32, 5.5, 1.5, 1.5 } }
cl:add(c:rect(24, 5, 33, 6))
O.shade(c, cl, CLD, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
O.dots(c, { { 24, 6 }, { 25, 6 }, { 26, 6 }, { 27, 6 }, { 28, 6 }, { 29, 6 }, { 30, 6 }, { 31, 6 }, { 32, 6 }, { 33, 6 } }, CLD[1])
O.dots(c, { { 26, 9 }, { 31, 9 } }, DROP[2]) O.dots(c, { { 26, 10 }, { 31, 10 } }, DROP[1])

O.done(c, "stone-sentry-perch")
