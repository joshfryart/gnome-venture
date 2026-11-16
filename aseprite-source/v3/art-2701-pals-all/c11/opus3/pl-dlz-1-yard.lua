-- Scalecrust Tot (pl-dlz-1), yard sprite 64x64. Opus richness pass (c11/opus3), built on c11/opus2.
-- Rootwarden, common, Dragonlizard Den. "A tiny scale that flakes off every time it laughs."
-- haiku drew a green bean blob with a stalk (no lizard read). Now: a baby lizard sitting up on its haunches,
-- oversized head, terracotta crust of round plates on the crown and back, pale peach belly, tail curled round
-- its feet. It is mid-laugh (wide open mouth, petal tongue).
-- quirk: one crust scale popping off the top of its head with little motion ticks, a pale bare spot where it was.
-- opus3: bead scales on head, body and tail (lit dot + lower-right shade), crust plates with a crackle line and a
-- lit top lip, a darker throat inside the laugh, toe claws, rim + cool bounce on every round part.
-- closer look: an earlier flake already lies on the ground by its foot (it laughs a lot).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-1-yard", 64)

local SKIN = { "#481a26", "#76283a", "#a43c3a", "#cc5a40", "#e88452", "#f6b47a" }
local CRST = { "#5a2a22", "#8a4a2c", "#b8763c", "#daa05a", "#f0c67e", "#fde2aa" }
local BELY = { "#94523e", "#c47e5a", "#e6aa7c", "#f6cfa0", "#fde6c0" }
local CLAW = { "#6a3a30", "#b07a5a", "#e6c09a" }

c:groundShadow(32, 58, 17, 2.5)

-- tail: curls out right and wraps round in front of the feet
local tail, tn = O.tube({ { 40, 51 }, { 55, 55 }, { 60, 46 }, { 53, 41 } }, function(t) return 3.6 * (1 - .7 * t) + .5 end)
local tI, tT = O.shadeN(c, tail, tn, SKIN, { amb = .22, wrap = .4, rim = true, bounce = "#6a5a8a", bmax = 2 })
O.tex(c, tI, tT, SKIN, function(x, y, i) if (x % 3 == 0) and i >= 3 then return -1 end end)
O.bumps(c, tI, tT, SKIN, 31, .88, 3)

-- body (pear) sitting up
local body = c:ellipse(32, 44, 11, 10)
local bI, bT = O.shade(c, body, SKIN, { sphere = { 27, 38, 15 }, amb = .2, wrap = .35, rim = true, bounce = "#6a5a8a", bmax = 2, sep = SKIN[1] })
-- crust plates on the flanks
O.tex(c, bI, bT, SKIN, function(x, y, i)
  local u, v = (x + (y // 3) % 2 * 2) % 4, y % 3
  if v == 0 and u ~= 3 then return -1 end
  if v == 1 and u == 1 and i >= 3 then return 1 end
end)
O.bumps(c, bI, bT, SKIN, 3, .93, 3)
-- belly
local belly = c:ellipse(32, 46, 6.5, 7.5)
local yI, yT = O.shade(c, belly, BELY, { sphere = { 30, 42, 9 }, amb = .35, wrap = .45, cuts = { .2, .4, .6, .82 }, sep = SKIN[2] })
O.tex(c, yI, yT, BELY, function(x, y, i) if y % 3 == 0 and y > 40 then return -1 end end) -- soft belly bands

-- hind legs (haunches) with toes
for _, s in ipairs({ { 21, 52, -1 }, { 43, 52, 1 } }) do
  local leg = c:ellipse(s[1], s[2], 5, 4)
  O.shade(c, leg, SKIN, { sphere = { s[1] - 2, s[2] - 3, 6 }, amb = .25, wrap = .4, rim = true, sep = SKIN[1] })
  O.shade(c, c:ellipse(s[1] - 1, s[2] - 2, 2.5, 1.8), CRST, { sphere = { s[1] - 2, s[2] - 3.5, 3 }, amb = .3, wrap = .4, sep = SKIN[2] })
  local fx = s[1] + s[3] * 2
  O.flat(c, c:rect(fx - 3, 56, fx + 3, 56), SKIN[3], "foot")
  O.dots(c, { { fx - 3, 57 }, { fx, 57 }, { fx + 3, 57 } }, CLAW[2])
end
-- little arms holding the belly (laughing so hard)
for _, a in ipairs({ { { 23, 39 }, { 22, 43 }, { 25, 46 }, { 28, 46 } }, { { 41, 39 }, { 42, 43 }, { 39, 46 }, { 36, 46 } } }) do
  local m, n = O.tube(a, function(t) return 1.8 - .4 * t end)
  O.shadeN(c, m, n, SKIN, { amb = .3, wrap = .45, sep = SKIN[1] })
end
O.dots(c, { { 28, 47 }, { 29, 46 }, { 36, 47 }, { 35, 46 } }, CLAW[3])

-- head: big, round snout
local head = c:ellipse(32, 25, 14, 11)
head:add(c:ellipse(32, 29, 12, 8))
local hI, hT = O.shade(c, head, SKIN, { sphere = { 26, 18, 18 }, amb = .25, wrap = .35, rim = true, bounce = "#6a5a8a", bmax = 2, sep = SKIN[1] })
O.bumps(c, hI, hT, SKIN, 9, .9, 3)
-- crust plates on the crown: rows of ochre shields over the brick skin
for _, q in ipairs({ { 27.5, 15 }, { 21.5, 18.5 }, { 42.5, 18.5 }, { 27, 19 }, { 38.5, 15 }, { 37, 19 }, { 32, 18.5 } }) do
  local pl = c:ellipse(q[1], q[2], 3, 2.4) pl:clip(head)
  O.shade(c, pl, CRST, { sphere = { q[1] - 1.2, q[2] - 2, 4 }, amb = .3, wrap = .4, sep = SKIN[2] })
  local cx, cy = math.floor(q[1]), math.floor(q[2])
  O.mark(c, { { cx, cy }, { cx + 1, cy + 1 } }, CRST[2]) -- crackle line
  O.mark(c, { { cx - 1, cy - 1 } }, CRST[6]) -- lit lip
end
-- crust plates down the back of the body (shoulders)
for _, q in ipairs({ }) do
  local pl = c:ellipse(q[1], q[2], 2, 2) pl:clip(body)
  O.shade(c, pl, CRST, { sphere = { q[1] - 1, q[2] - 1.5, 3 }, amb = .25, wrap = .4, sep = SKIN[2] })
end
-- bare pale spot where the flake came off
local bare = c:ellipse(33.5, 15.5, 2.5, 1.5) bare:clip(head)
O.flat(c, bare, BELY[4], "bare") O.dots(c, { { 32, 16 }, { 33, 17 }, { 34, 17 }, { 35, 16 } }, BELY[2])
-- brow ridges
O.dots(c, { { 21, 18 }, { 22, 17 }, { 23, 17 }, { 40, 17 }, { 41, 17 }, { 42, 18 } }, SKIN[2])

-- laughing mouth: wide open, petal tongue, pale chin
local mouth = c:poly{ { 25, 29 }, { 39, 29 }, { 37, 33 }, { 32, 35 }, { 27, 33 } }
O.flat(c, mouth, "#4a1a2a", "mouth")
O.dots(c, { { 29, 30 }, { 30, 30 }, { 31, 30 }, { 32, 30 }, { 33, 30 }, { 34, 30 }, { 35, 30 } }, "#30121e") -- deep throat
O.flat(c, c:ellipse(32, 33, 3, 1.2), P.petal.base, "tongue")
O.dots(c, { { 31, 32 }, { 32, 32 } }, P.petal.hi)
for x = 25, 39 do O.dot(c, x, 28, P.ink) end
O.dots(c, { { 27, 30 }, { 37, 30 } }, CLAW[3]) -- two tiny egg teeth
-- nostrils
O.dots(c, { { 30, 25 }, { 34, 25 } }, SKIN[1])
-- eyes
c:eyeLocked(22, 20)
c:eyeLocked(37, 20)
c:cheek(19, 27) c:cheek(43, 27)

-- an older flake lying on the ground by the right foot
O.shade(c, c:ellipse(51, 57, 2, 1), CRST, { R = 1, amb = .35, wrap = .45, cuts = { .25, .45, .65, .85 } })
-- quirk: the flake popping off the top of its head
local flake = c:ellipse(41, 6, 3, 2.2)
O.shade(c, flake, CRST, { sphere = { 39.5, 4.5, 4 }, amb = .3, wrap = .4 })
O.dots(c, { { 39, 7 }, { 40, 7 }, { 41, 8 }, { 42, 8 } }, CRST[2]) -- underside, where it tore off

O.done(c, "pl-dlz-1-yard", function(c)
  -- motion ticks under the flake (un-outlined, solid ink-ish)
  for _, p in ipairs({ { 36, 11 }, { 37, 10 }, { 40, 12 }, { 40, 11 }, { 46, 10 }, { 47, 11 } }) do c:put(p[1], p[2], CRST[5]) end
end)
