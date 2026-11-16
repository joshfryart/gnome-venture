-- Tongue Flicker (pl-dlz-2), perch sprite 36x36. Opus richness pass (c11/opus3), hand-built at this size.
-- Teal chameleon on a twig: helmet casque, spiral tail under the twig, cream side stripe, pink blossom at the twig
-- tip. 2x3 pill eyes on the head turned to us. opus3: crest beads, lit casque ridge, twig grain, bounce light,
-- and the pink-matching front toes by the blossom. quirk: the red forked tongue arcing up past the fly (missed).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-dlz-2-perch", 36)

local TEAL = { "#14303c", "#1a4c58", "#1f726c", "#34a07c", "#66c88a", "#b0e6a2" }
local STRP = { "#d8e8b0", "#f4f4cc" }
local TWIG = { "#3a2226", "#5e3a2e", "#86583a", "#ad7c4c", "#d0a46a" }
local TONG = { "#6a1630", "#a8243a", "#d84446", "#f2785e" }
local FLY  = { "#3a3248", "#5e5878", "#c8e0ec" }

c:groundShadow(18, 33, 11, 1)
local twig, twn = O.tube({ { 3, 27 }, { 12, 25 }, { 22, 26 }, { 31, 24 } }, function(t) return 1.4 - .4 * t end)
local gI, gT = O.shadeN(c, twig, twn, TWIG, { amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 }, rim = true })
O.tex(c, gI, gT, TWIG, function(x, y, i) if x % 4 == 0 then return -1 end end)
-- blossom
for _, q in ipairs({ { 30, 21 }, { 32, 22 }, { 30, 23 } }) do O.shade(c, c:ellipse(q[1], q[2], 1, 1), { P.petal.deep, P.petal.shade, P.petal.base, P.petal.hi }, { R = 1, amb = .45, wrap = .5, cuts = { .25, .5, .78 } }) end
O.dot(c, 31, 22, "#f5b82e")
-- tail curl
local tail, tn = O.tube({ { 8, 22 }, { 4, 26 }, { 5, 31 }, { 10, 30 } }, function(t) return 1.8 * (1 - .5 * t) end)
O.shadeN(c, tail, tn, TEAL, { amb = .25, wrap = .4, rim = true, bounce = "#4a5a8a", bmax = 2 })
O.dots(c, { { 9, 29 }, { 8, 28 } }, TEAL[2])
-- body
local body = c:ellipse(13, 20, 7, 5)
body:add(c:poly{ { 7, 19 }, { 13, 14 }, { 19, 16 }, { 20, 21 } })
O.shade(c, body, TEAL, { sphere = { 10, 15, 9 }, amb = .25, wrap = .4, rim = true, bounce = "#4a5a8a", bmax = 2, sep = TEAL[1] })
O.dots(c, { { 10, 15 }, { 12, 14 }, { 14, 14 } }, TEAL[6])
for x = 8, 18 do O.mark(c, { { x, 21 + (x > 15 and 1 or 0) } }, x % 2 == 0 and STRP[1] or STRP[2]) end
O.mark(c, { { 11, 18 }, { 16, 17 } }, P.petal.base)
-- legs gripping
for _, L in ipairs({ { 9, 23, 8, 25 }, { 17, 23, 18, 25 } }) do
  O.flat(c, c:rect(math.min(L[1], L[3]), L[2], math.max(L[1], L[3]), L[4]), TEAL[3], "leg")
  O.dot(c, L[1], L[2], TEAL[4])
end
O.dot(c, 18, 25, P.petal.base) -- toes gone pink, matching the blossom
-- casque + head
O.shade(c, c:poly{ { 16, 15 }, { 18, 8 }, { 22, 9 }, { 23, 13 } }, TEAL, { R = 1, amb = .3, wrap = .4, rim = true, sep = TEAL[1] })
O.dots(c, { { 19, 10 }, { 20, 11 } }, TEAL[2])
local head = c:ellipse(21.5, 15, 5.5, 4.5)
O.shade(c, head, TEAL, { sphere = { 19, 12, 7 }, amb = .3, wrap = .4, rim = true, bounce = "#4a5a8a", bmax = 2, sep = TEAL[1] })
O.dots(c, { { 19, 18 }, { 20, 18 }, { 21, 18 }, { 22, 18 }, { 23, 18 } }, P.ink)
-- tongue arc, missing the fly
local tongue, ton = O.tube({ { 24, 18 }, { 29, 20 }, { 32, 14 }, { 31, 8 } }, function(t) return .8 end)
O.shadeN(c, tongue, ton, TONG, { amb = .35, wrap = .45, cuts = { .25, .5, .78 } })
O.dots(c, { { 30, 6 }, { 32, 6 } }, TONG[3])
c:eyeSmall(18, 13)
c:eyeSmall(23, 13)
O.dot(c, 26, 16, P.petal.base)
-- fly
O.dots(c, { { 25, 3 }, { 27, 3 } }, FLY[3])
O.flat(c, c:rect(25, 4, 26, 5), FLY[1], "fly")

O.done(c, "pl-dlz-2-perch")
