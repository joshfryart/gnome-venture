-- Tongue Flicker (pl-dlz-2), yard sprite 64x64. Opus richness pass (c11/opus3), built on c11/opus2.
-- Bloomcaller, common, Dragonlizard Den. "A forked red tongue that flicks at flies and misses on purpose."
-- haiku drew a yellow bean with a beak-like snout (read as a duck). Now a different species from its den mates:
-- a teal chameleon gripping a blossoming twig with mitten feet, tall helmet casque, spiral tail curled under the
-- twig, cream side stripe and pink freckles, head turned to us.
-- quirk: the forked red tongue shot out in a long arc, missing the fly by a wide, polite margin.
-- opus3: granule beads over body, head and tail, ridged casque with a lit edge, saw-tooth back crest, eye-turret
-- rings, bark grain and nodes on the twig, leaf midribs, a sticky pad on the tongue tip, rim + cool bounce.
-- closer look: the chameleon is colour-matching: the toes gripping near the blossom have gone pink.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-2-yard", 64)

local TEAL = { "#14303c", "#1a4c58", "#1f726c", "#34a07c", "#66c88a", "#b0e6a2" }
local STRP = { "#8ab08a", "#d8e8b0", "#f4f4cc" }
local TWIG = { "#3a2226", "#5e3a2e", "#86583a", "#ad7c4c", "#d0a46a" }
local TONG = { "#6a1630", "#a8243a", "#d84446", "#f2785e" }
local LEAF = { "#2a4a2a", "#3e7032", "#62a03e", "#9acc5a" }
local FLY  = { "#3a3248", "#5e5878", "#c8e0ec" }

c:groundShadow(32, 60, 18, 2)

-- the twig, a slight diagonal, with a side shoot
local twig, twn = O.tube({ { 5, 49 }, { 20, 46 }, { 40, 47 }, { 58, 44 } }, function(t) return 2.2 - .8 * t end)
local gI, gT = O.shadeN(c, twig, twn, TWIG, { amb = .25, wrap = .4, cuts = { .25, .45, .65, .85 }, rim = true })
O.tex(c, gI, gT, TWIG, function(x, y, i) if x % 5 == 0 then return -1 end if (x % 5 == 1) and i >= 3 then return 1 end end)
O.dots(c, { { 27, 45 }, { 28, 45 } }, TWIG[5]) O.dots(c, { { 27, 46 }, { 28, 46 } }, TWIG[1]) -- a bark node
local shoot, shn = O.tube({ { 44, 46 }, { 47, 50 }, { 50, 53 }, { 52, 55 } }, function(t) return 1.2 - .5 * t end)
O.shadeN(c, shoot, shn, TWIG, { amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 } })
-- leaves on the shoot
for _, l in ipairs({ { { 52, 55 }, { 55, 53 }, { 58, 54 }, { 60, 57 } }, { { 8, 48 }, { 6, 44 }, { 7, 41 }, { 10, 39 } } }) do
  local m, n = O.tube(l, function(t) return 2.4 * math.sin(math.pi * t) + .3 end)
  local lI, lT = O.shadeN(c, m, n, LEAF, { amb = .3, wrap = .45, cuts = { .25, .5, .78 }, sep = LEAF[1], rim = true })
  for k = 2, 8 do local x, y = O.bez(l, k / 10) O.mark(c, { { math.floor(x + .5), math.floor(y + .5) } }, LEAF[4]) end -- midrib
end

-- a blossom at the twig tip (bloomcaller)
for _, q in ipairs({ { 54, 39 }, { 58, 39 }, { 56, 37 }, { 55, 42 }, { 58, 42 } }) do
  O.shade(c, c:ellipse(q[1], q[2], 1.6, 1.6), { P.petal.deep, P.petal.shade, P.petal.base, P.petal.hi }, { sphere = { q[1] - 1, q[2] - 1, 2.5 }, amb = .35, wrap = .45, cuts = { .25, .5, .78 }, sep = P.petal.deep })
end
O.flat(c, c:rect(56, 40, 57, 41), "#f5b82e", "pollen") O.dot(c, 56, 40, "#ffe38a")

-- spiral tail hanging under the twig
local tail, tn = O.tube({ { 16, 40 }, { 10, 46 }, { 12, 56 }, { 19, 55 } }, function(t) return 3 * (1 - .55 * t) end)
local tI, tT = O.shadeN(c, tail, tn, TEAL, { amb = .22, wrap = .4, rim = true, bounce = "#4a5a8a", bmax = 2 })
O.bumps(c, tI, tT, TEAL, 41, .82, 3)
local curl, cn = O.tube({ { 19, 55 }, { 22, 53 }, { 20, 49 }, { 17, 51 } }, function(t) return 1.4 - .4 * t end)
O.shadeN(c, curl, cn, TEAL, { amb = .25, wrap = .4, sep = TEAL[1] })

-- body: tall, flattened, arched back with a little crest
local body = c:ellipse(25, 37, 12, 8)
body:add(c:poly{ { 14, 36 }, { 24, 27 }, { 34, 30 }, { 36, 38 } })
local bI, bT = O.shade(c, body, TEAL, { sphere = { 20, 30, 15 }, amb = .2, wrap = .35, rim = true, bounce = "#4a5a8a", bmax = 2, sep = TEAL[1] })
-- skin granules
O.bumps(c, bI, bT, TEAL, 43, .86, 3)
-- cream side stripe
for x = 15, 33 do
  local y = 38 + math.floor(((x - 24) / 9) ^ 2 * 2)
  O.mark(c, { { x, y } }, x < 26 and STRP[2] or STRP[1])
  if x % 3 == 0 then O.mark(c, { { x, y - 1 } }, STRP[3]) end
end
-- pink freckles
O.mark(c, { { 20, 33 }, { 27, 32 }, { 23, 42 }, { 30, 41 } }, P.petal.base)
-- back crest bumps
O.dots(c, { { 17, 32 }, { 19, 30 }, { 21, 28 }, { 23, 27 }, { 25, 26 }, { 27, 26 } }, TEAL[6]) -- saw-tooth crest
O.dots(c, { { 18, 32 }, { 20, 30 }, { 22, 28 }, { 24, 27 }, { 26, 27 } }, TEAL[3])

-- legs gripping the twig, mitten feet
for _, L in ipairs({ { { 18, 42 }, { 16, 44 }, { 16, 46 }, { 17, 47 } }, { { 32, 41 }, { 34, 43 }, { 35, 45 }, { 35, 47 } } }) do
  local m, n = O.tube(L, function(t) return 2 - .3 * t end)
  O.shadeN(c, m, n, TEAL, { amb = .3, wrap = .4, sep = TEAL[1] })
  local fx, fy = L[4][1], L[4][2]
  O.flat(c, c:rect(fx - 2, fy, fx + 2, fy + 1), TEAL[3], "mitt")
  O.dots(c, { { fx - 2, fy + 2 }, { fx + 2, fy + 2 } }, TEAL[2])
end
O.dots(c, { { 33, 47 }, { 34, 47 }, { 35, 47 }, { 36, 47 }, { 37, 47 } }, P.petal.shade) O.dots(c, { { 33, 47 }, { 34, 47 } }, P.petal.base) -- pink-matching toes

-- head turned to us, helmet casque sweeping back
local casque = c:poly{ { 29, 27 }, { 33, 16 }, { 39, 18 }, { 42, 24 } }
local qI, qT = O.shade(c, casque, TEAL, { R = 2, amb = .25, wrap = .4, rim = true, sep = TEAL[1] })
O.tex(c, qI, qT, TEAL, function(x, y, i) if (x - y) % 3 == 0 then return -1 end if (x - y) % 3 == 1 and i >= 3 then return 1 end end)
local head = c:ellipse(39, 28, 9, 7.5)
local hI, hT = O.shade(c, head, TEAL, { sphere = { 35, 24, 11 }, amb = .25, wrap = .35, rim = true, bounce = "#4a5a8a", bmax = 2, sep = TEAL[1] })
O.bumps(c, hI, hT, TEAL, 47, .9, 3)
-- pale lips / jaw line
O.dots(c, { { 34, 33 }, { 35, 34 }, { 36, 34 }, { 37, 34 }, { 38, 34 }, { 39, 34 }, { 40, 34 }, { 41, 33 } }, STRP[2])
O.dots(c, { { 36, 33 }, { 37, 33 }, { 38, 33 }, { 39, 33 }, { 40, 33 } }, P.ink)

-- quirk: forked tongue flung out in an arc, missing the fly
local tongue, ton = O.tube({ { 42, 33 }, { 50, 36 }, { 56, 28 }, { 55, 17 } }, function(t) return 1.2 - .25 * t end)
O.shadeN(c, tongue, ton, TONG, { amb = .3, wrap = .45, cuts = { .25, .5, .78 } })
-- fork
O.dots(c, { { 53, 15 }, { 52, 14 }, { 56, 15 }, { 57, 14 } }, TONG[3])
O.dots(c, { { 54, 16 }, { 55, 16 } }, TONG[3]) O.dot(c, 54, 17, TONG[4]) -- sticky pad
O.dots(c, { { 54, 31 }, { 55, 30 } }, TONG[4])
-- tongue base: a petal shine inside the mouth corner
O.dot(c, 41, 33, TONG[2])

-- face: eye turrets (a ring of scaly lid round each locked eye)
for _, e in ipairs({ { 33, 23 }, { 40, 23 } }) do
  O.flat(c, c:ellipse(e[1] + 2, e[2] + 2, 3.6, 3.6), TEAL[3], "turret")
  O.dots(c, { { e[1], e[2] - 1 }, { e[1] + 1, e[2] - 1 }, { e[1] - 1, e[2] } }, TEAL[5])
end
c:eyeLocked(33, 23)
c:eyeLocked(40, 23)
c:cheek(31, 30) c:cheek(45, 29)
O.dots(c, { { 46, 27 } }, TEAL[1]) -- nostril

-- the fly, well out of reach
O.flat(c, c:ellipse(44.5, 6.5, 1.6, 1.2), FLY[3], "wing") O.flat(c, c:ellipse(49.5, 6.5, 1.6, 1.2), FLY[3], "wing")
local fly = c:ellipse(47, 10, 2, 1.5)
O.flat(c, fly, FLY[1], "fly") O.dots(c, { { 46, 9 }, { 47, 9 } }, FLY[2])

O.done(c, "pl-dlz-2-yard", function(c)
  -- buzz ticks round the fly
  for _, p in ipairs({ { 41, 9 }, { 40, 11 }, { 53, 9 }, { 54, 11 } }) do c:put(p[1], p[2], FLY[2]) end
end)
