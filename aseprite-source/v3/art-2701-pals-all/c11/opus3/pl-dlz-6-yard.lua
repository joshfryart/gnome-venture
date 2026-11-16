-- Mossback Monitor (pl-dlz-6), yard sprite 64x64. Opus richness pass (c11/opus3), built on c11/opus2.
-- Thornblade, rare, Dragonlizard Den. "A pocket-sized monitor lizard, polished by a hundred jungle naps."
-- haiku drew a green lizard close in colour and shape to its den mates. Now a long slate-blue monitor lying on a
-- big jungle leaf it naps on, long neck raised, cream rosette spots, a cushion of yellow-green moss (with two tiny
-- red toadstools) grown on its back, long tail wrapped round the leaf tip. Rare touches: a gold claw band and the
-- leaf's gold midrib.
-- quirk: polished by naps: bright glossy shine streaks along its back, neck and head, with sparkles.
-- opus3: the head is much bigger (was small next to the moss cushion) and the cushion smaller; bead scales with a
-- lit dot + lower-right shade, ocellus rosettes (cream ring, dark eye), neck folds, a forked tongue tip, rim + bounce.
-- closer look: a dewdrop on the curled leaf tip, and a third toadstool that is only a button just poking up.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-6-yard", 64)

local MON  = { "#1c1c2c", "#2a2e42", "#3e4858", "#5a6a70", "#84968c", "#b8c6a8" }
local ROSE = { "#c4b884", "#ece0b0" }
local LEAF = { "#14363a", "#1c5448", "#287658", "#40a06a", "#78c880", "#b4e8a0" }
local MOSS = { "#3a4418", "#5c6c22", "#86a030", "#b6cc48", "#e0ea7a" }
local MUSH = { "#7a2030", "#c43a3a", "#ee6a4a", "#fde0b0" }
local GOLD = { "#8a5a1a", "#e0a032", "#ffe08a" }
local SHIN = "#eef0c8"

c:groundShadow(32, 59, 27, 2.5)

-- the nap leaf, lying flat, tip curling up on the left
local leaf = c:ellipse(32, 52, 27, 5)
leaf:add(c:poly{ { 6, 51 }, { 4, 46 }, { 9, 49 } })
local lI, lT = O.shade(c, leaf, LEAF, { R = 3, amb = .25, wrap = .4, rim = true })
O.tex(c, lI, lT, LEAF, function(x, y, i) if (x - 32 + (y - 52) * 3) % 6 == 0 and y ~= 52 then return -1 end end) -- side veins
for x = 6, 58 do O.mark(c, { { x, 52 } }, x % 2 == 0 and GOLD[2] or LEAF[5]) end -- gold midrib

-- tail wrapping round the leaf tip
local tail, tn = O.tube({ { 18, 45 }, { 7, 43 }, { 5, 54 }, { 16, 56 } }, function(t) return 3.8 * (1 - .8 * t) + .4 end)
local tI, tT = O.shadeN(c, tail, tn, MON, { amb = .25, wrap = .4, rim = true, bounce = "#5a6a9a", bmax = 2, sep = MON[1] })
O.tex(c, tI, tT, MON, function(x, y, i) if (x + y) % 4 == 0 and i >= 3 then return 1 end end)

-- hind leg behind
local m, n = O.tube({ { 20, 46 }, { 17, 48 }, { 15, 49 }, { 13, 50 } }, function(t) return 2 - .4 * t end)
O.shadeN(c, m, n, MON, { amb = .25, wrap = .4, sep = MON[1] })

-- long low body
local body = c:ellipse(28, 41, 15, 7.5)
local bI, bT = O.shade(c, body, MON, { sphere = { 25, 33, 22 }, amb = .32, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 2, sep = MON[1] })
-- bead scales + cream rosettes (small rings)
O.bumps(c, bI, bT, MON, 13, .8, 2)
for _, q in ipairs({ { 17, 42 }, { 24, 45 }, { 31, 45 }, { 37, 42 }, { 20, 38 }, { 34, 38 }, { 27, 41 } }) do
  O.mark(c, { { q[1], q[2] - 1 }, { q[1] + 1, q[2] - 1 }, { q[1] - 1, q[2] }, { q[1] + 2, q[2] }, { q[1], q[2] + 1 }, { q[1] + 1, q[2] + 1 } }, ROSE[1])
  O.mark(c, { { q[1], q[2] - 1 }, { q[1] - 1, q[2] } }, ROSE[2])
  O.mark(c, { { q[1], q[2] }, { q[1] + 1, q[2] } }, MON[2])
end
-- belly line on the leaf
for x = 15, 41 do O.mark(c, { { x, 47 } }, MON[2]) end

-- legs splayed on the leaf, front leg with a gold claw band
for _, L in ipairs({ { 40, 45, 44, 50 }, { 25, 46, 24, 51 } }) do
  local m, n = O.tube({ { L[1], L[2] }, { L[1] + 1, L[2] + 2 }, { L[3], L[4] - 1 }, { L[3], L[4] } }, function(t) return 2.1 - .4 * t end)
  O.shadeN(c, m, n, MON, { amb = .3, wrap = .45, sep = MON[1] })
  O.flat(c, c:rect(L[3] - 2, L[4] + 1, L[3] + 2, L[4] + 1), MON[3], "foot")
  O.dots(c, { { L[3] - 3, L[4] + 1 }, { L[3] + 3, L[4] + 1 } }, MON[5])
end
O.dots(c, { { 42, 49 }, { 43, 49 }, { 44, 49 } }, GOLD[2]) O.dot(c, 42, 49, GOLD[3])

-- neck and head raised to the right
local neck, nn = O.tube({ { 37, 39 }, { 42, 36 }, { 44, 31 }, { 45, 25 } }, function(t) return 5 - .8 * t end)
local nI, nT = O.shadeN(c, neck, nn, MON, { amb = .25, wrap = .4, rim = true, bounce = "#5a6a9a", bmax = 2 })
O.tex(c, nI, nT, MON, function(x, y, i) if y % 3 == 0 and i >= 3 then return -1 end end) -- neck folds
local head = c:ellipse(46, 19, 11, 8.5)
head:add(c:ellipse(55, 23, 7, 5))
local hI, hT = O.shade(c, head, MON, { sphere = { 42, 13, 16 }, amb = .38, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 2, sep = MON[1] })
O.bumps(c, hI, hT, MON, 17, .9, 3)
-- long mouth line, a calm smile
O.dots(c, { { 42, 21 }, { 43, 22 }, { 44, 23 }, { 45, 23 }, { 46, 23 }, { 47, 23 }, { 48, 23 }, { 49, 23 }, { 50, 23 }, { 51, 23 }, { 52, 23 }, { 53, 23 }, { 54, 23 }, { 55, 23 }, { 56, 23 }, { 57, 22 } }, P.ink)
O.dots(c, { { 45, 24 }, { 46, 24 }, { 47, 24 }, { 48, 24 }, { 49, 24 }, { 50, 24 }, { 51, 24 }, { 52, 24 }, { 53, 24 } }, MON[5]) -- pale jaw
O.dot(c, 59, 21, MON[1]) -- nostril
c:eyeLocked(39, 13)
c:eyeLocked(48, 13)
c:cheek(38, 19) c:cheek(53, 19)

-- moss cushion grown on the back, two tiny toadstools
local moss = c:ellipse(25, 34, 8, 2.8)
moss:add(c:ellipse(19, 35, 3.5, 2.2)) moss:add(c:ellipse(30, 34, 3.5, 2.6))
local mI, mT = O.shade(c, moss, MOSS, { sphere = { 22, 31, 10 }, amb = .3, wrap = .45, cuts = { .2, .42, .65, .85 }, sep = MON[2] })
O.tex(c, mI, mT, MOSS, function(x, y, i) if H(x, y, 11) > .7 then return 1 end if H(x, y, 12) > .8 then return -1 end end)
for _, mu in ipairs({ { 21, 28 }, { 27, 27 } }) do
  O.flat(c, c:rect(mu[1], mu[2] + 2, mu[1] + 1, mu[2] + 4), MUSH[4], "stalk")
  local cap = c:ellipse(mu[1] + .5, mu[2] + 1, 2.5, 1.5) cap:cut(c:rect(0, mu[2] + 2, 63, 63))
  O.shade(c, cap, MUSH, { R = 1, amb = .35, wrap = .45, cuts = { .25, .5, .78 }, sep = MUSH[1] })
  O.dot(c, mu[1], mu[2], MUSH[4])
end

-- quirk: polish shine streaks (back, neck and head)
for _, p in ipairs({ { 34, 35 }, { 35, 35 }, { 36, 36 }, { 14, 38 }, { 15, 37 }, { 16, 37 }, { 41, 9 }, { 42, 9 }, { 43, 9 }, { 44, 10 },
  { 55, 18 }, { 56, 18 }, { 57, 19 }, { 41, 30 }, { 41, 29 }, { 42, 28 } }) do O.mark(c, { p }, SHIN) end
-- third toadstool: only a button poking out of the moss
O.dots(c, { { 31, 31 } }, MUSH[2]) O.dot(c, 32, 31, MUSH[1])
-- forked tongue tip just peeking out of the snout
O.dots(c, { { 59, 23 }, { 60, 23 }, { 61, 22 }, { 61, 24 } }, "#c43a5a")
-- dewdrop on the curled leaf tip
O.dot(c, 6, 46, "#c8ecec") O.dot(c, 6, 47, "#78b4c4")

O.shift(c, -1, 0)
O.done(c, "pl-dlz-6-yard", function(c)
  c:sparkle(37, 31)
  c:sparkle(60, 9)
end)
