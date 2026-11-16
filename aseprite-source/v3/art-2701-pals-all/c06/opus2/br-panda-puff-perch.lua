-- Panda Puff (br-panda-puff), perch sprite 36x36. Opus second pass (art-2701-pals-all/c06/opus2), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: cream-white panda with cool lilac shade, dark ears, arms
-- and legs, a bamboo stalk held up to its mouth with a leaf sprig. The eye patches are a mid plum so the
-- c:eyeSmall ink pills still read inside them (a cream rim under each pill).
-- quirk: one bite out of the stalk top and a leaf still sticking out of its mouth, mid-chew.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-panda-puff-perch", 36)

local FUR  = { "#6a6084", "#9a92ae", "#c4bccc", "#e2dcde", "#f2eee8", "#fbf8f2" }
local DARK = { "#1e1826", "#2e2638", "#40364c", "#564a62", "#706480" }
local PAT  = { "#5a4c6a", "#6e6080", "#82749a" }
local BAMB = { "#1f4a2a", "#2e6a34", "#4a8e3e", "#6eb04c", "#a2d06a", "#d4ec9a" }
local LEAF = { "#1f3b2e", "#2c6a3a", "#4a9a48", "#7cc45c" }
local BNC  = "#6a8aa8"

c:groundShadow(18, 33, 11, 1.5)
for _, x in ipairs({ 12, 24 }) do O.shade(c, c:ellipse(x, 30.5, 3.5, 2), DARK, { R = 1, amb = .35, rim = true, cuts = { .25, .45, .65, .85 } }) end
O.shade(c, c:ellipse(18, 25, 9.5, 6.5), FUR, { sphere = { 14, 21, 11 }, amb = .3, wrap = .4, sep = FUR[1], rim = true, bounce = BNC, bmax = 2 })
for _, e in ipairs({ { 10, 6 }, { 26, 6 } }) do
  O.shade(c, c:ellipse(e[1], e[2], 3, 2.5), DARK, { sphere = { e[1] - 1, e[2] - 1, 3 }, amb = .35, rim = true, cuts = { .25, .45, .65, .85 } })
end
O.shade(c, c:ellipse(18, 13.5, 10.5, 7.5), FUR, { sphere = { 14, 9, 12 }, amb = .32, wrap = .4, sep = FUR[1], rim = true })
for _, p in ipairs({ { 12, 14, -1 }, { 23, 14, 1 } }) do
  local m = c:ellipse(p[1] + .5, p[2], 2.5, 2.5)
  m:add(c:rect(p[1] + (p[3] < 0 and -2 or 1), p[2] + 1, p[1] + (p[3] < 0 and 0 or 3), p[2] + 3))
  O.flat(c, m, PAT[2], "patch")
end
c:eyeSmall(12, 13) c:eyeSmall(23, 13)
O.dots(c, { { 17, 17 }, { 18, 17 } }, DARK[2])
O.dots(c, { { 17, 19 }, { 18, 19 } }, P.ink)
c:cheek(8, 18) c:cheek(26, 18)

local stalk = c:poly{ { 26, 34 }, { 28, 34 }, { 22, 18 }, { 20, 18 } }
local sb = {} stalk:each(function(x, y) if y == 27 then sb[K(x, y)] = -2 end end)
O.shade(c, stalk, BAMB, { R = 1, amb = .35, bias = sb, sep = BAMB[1], rim = true })
c.pix[18 * c.w + 20] = nil c.own[18 * c.w + 20] = nil
O.mark(c, { { 21, 18 } }, "#e6eebc")
O.shade(c, c:poly{ { 26, 27 }, { 31, 23 }, { 33, 22 }, { 29, 26 } }, LEAF, { R = 1, amb = .35, sep = LEAF[1], cuts = { .3, .55, .8 } })
local ra, rn = O.tube({ { 26, 21 }, { 27, 24 }, { 25, 26 }, { 24, 26 } }, function(t) return 1.6 end)
O.shadeN(c, ra, rn, DARK, { amb = .3, sep = DARK[1], cuts = { .25, .45, .65, .85 } })
local la, ln = O.tube({ { 10, 21 }, { 9, 24 }, { 11, 26 }, { 14, 27 } }, function(t) return 1.6 end)
O.shadeN(c, la, ln, DARK, { amb = .3, sep = DARK[1], rim = true, cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 16, 19 }, { 15, 19 }, { 14, 20 }, { 13, 20 } }, LEAF[3]) O.dot(c, 14, 19, LEAF[4])

O.shift(c, 0, -1)
O.done(c, "br-panda-puff-perch")
