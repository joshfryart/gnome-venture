-- Slag Drip (pl-cwy-2), yard sprite 64x64. Opus richness pass (c11/opus3), built on c11/opus2.
-- Seedkeeper, common, Forge of the Cinder Wyrm. "A thick glowing drip that takes its time falling off the forge."
-- haiku drew a red flask under a grey cap (read as a potion bottle). Now the drip hangs from a dark riveted iron
-- forge lip: a thick molten neck stretching into a heavy glowing bulb (white-hot core, orange body, red base),
-- with patches of cooling dark crust on the neck and a small puddle glowing on the floor below.
-- quirk: it takes its time: one little molten hand still holding the forge lip, a calm smile, and a tiny droplet
-- that has only just let go.
-- opus3: hammered iron (pits with lit lips), a lit top bevel and dark under-chamfer on the beam, domed rivets,
-- the iron glowing dull red where the slag sits on it, cooling crust flakes (dark plates with a lit lip) on the neck
-- (opus2's dithered base is now a solid wavy red band), flow streaks, warm bounce under the bulb, ripple rings in the puddle.
-- closer look: a bubble rising in the bulb, about to pop, and the drip's glow reflected on the beam's underside.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-2-yard", 64)

local SLAG = { "#6a1a1e", "#a82c1c", "#e05a1e", "#f8962e", "#ffcc56", "#fff0a0" }
local CRST = { "#4a1a1e", "#6e2622", "#8e3a26" }
local IRON = { "#1a1822", "#2a2632", "#3e3848", "#585060", "#7c7484", "#a49caa" }

-- glowing puddle on the floor
local pud = c:ellipse(32, 59, 9, 1)
O.shade(c, pud, SLAG, { R = 1, amb = .3, wrap = .4, cuts = { .2, .4, .6, .8, .95 } })

-- the forge lip: a thick riveted iron beam
local beam = c:rrect(4, 4, 59, 12, 2)
local iI, iT = O.shade(c, beam, IRON, { R = 3, amb = .25, wrap = .4, rim = true })
O.bumps(c, iI, iT, IRON, 9, .92, 2) -- hammer pits
O.tex(c, iI, iT, IRON, function(x, y, i) if y == 5 and x > 5 and x < 58 then return 1 end end) -- lit top bevel
for x = 4, 59 do O.mark(c, { { x, 11 } }, IRON[2]) O.mark(c, { { x, 12 } }, IRON[1]) end -- bottom chamfer
-- iron glowing dull red where the hot slag sits on it
beam:each(function(x, y) local d = math.abs(x - 31) if d < 13 and y >= 6 and y <= 10 and c:get(x, y) then local q = y * c.w + x if d < 8 then c.pix[q] = (y < 9 and "#7a3036" or "#5a2630") elseif y >= 8 then c.pix[q] = "#4a2430" end end end)
-- the drip's glow reflected on the under-chamfer
for x = 22, 40 do O.mark(c, { { x, 12 } }, (math.abs(x - 31) < 6) and "#8a3a26" or "#6a2a26") end
for _, rx in ipairs({ 9, 20, 44, 54 }) do
  O.dots(c, { { rx - 1, 7 }, { rx, 6 }, { rx + 1, 7 }, { rx, 8 } }, IRON[4]) O.dot(c, rx, 7, IRON[5]) O.dot(c, rx - 1, 6, IRON[6]) O.dot(c, rx + 1, 8, IRON[1]) O.dot(c, rx, 9, IRON[2])
end
-- hot slag sitting along the lip edge


-- the drip: neck stretching down to a heavy bulb
local drip, dn = O.tube({ { 31, 8 }, { 28, 18 }, { 35, 22 }, { 32, 30 } }, function(t) return 3.2 + 4.5 * t * t end)
drip:add(c:ellipse(32, 37, 13, 11))
drip:add(c:ellipse(31, 5, 10, 2)) -- the pool on top of the beam, spilling over the front edge
drip:add(c:ellipse(31, 13.5, 6, 1.5))
drip:clip(c:rect(0, 3, 63, 63))
local dI, dT = O.shade(c, drip, SLAG, { sphere = { 27, 28, 20 }, amb = .18, wrap = .32, rim = true, bounce = "#c8401c", bmax = 2 })
-- white-hot core, red sinking to the base
O.flat(c, c:ellipse(27, 30, 2.5, 1.5), SLAG[6], "core")
drip:each(function(x, y)
  local q = y * c.w + x
  if c.own[q] == dT and y >= 46 + math.floor(math.sin(x * .55) * 1.3) then c.pix[q] = (y >= 48 and SLAG[2] or SLAG[3]) end
end)
-- cooling skin: darker drag lines down the neck
for _, s2 in ipairs({ { 29, 14, 4 }, { 33, 19, 3 } }) do
  for k = 0, s2[3] do O.mark(c, { { s2[1] + (k // 3), s2[2] + k } }, k % 2 == 0 and SLAG[3] or SLAG[4]) end
end
-- cooling crust flakes on the neck and shoulders: dark plates, lit upper-left lip, glowing seam below
for _, f in ipairs({ { 33, 14, 3 }, { 28, 21, 2 } }) do
  for k = 0, f[3] do O.mark(c, { { f[1] + k, f[2] }, { f[1] + k, f[2] + 1 } }, CRST[(k == 0) and 3 or 2]) end
  O.mark(c, { { f[1], f[2] - 1 }, { f[1] + 1, f[2] - 1 } }, CRST[3]) O.mark(c, { { f[1] + 1, f[2] + 2 }, { f[1] + f[3], f[2] + 2 } }, SLAG[5])
end
-- a bubble rising in the bulb, about to pop
O.mark(c, { { 36, 43 }, { 37, 42 }, { 38, 43 }, { 37, 44 } }, SLAG[6]) O.mark(c, { { 37, 43 } }, SLAG[3])
-- surface flow streaks
for _, s in ipairs({ { 38, 30 }, { 40, 34 }, { 41, 38 }, { 24, 41 }, { 25, 44 } }) do O.mark(c, { s, { s[1], s[2] + 1 } }, SLAG[4]) end

-- quirk: a little molten hand still holding the forge lip
local arm, an = O.tube({ { 22, 28 }, { 17, 25 }, { 15, 19 }, { 16, 14 } }, function(t) return 1.9 - .3 * t end)
O.shadeN(c, arm, an, SLAG, { amb = .35, wrap = .45, sep = SLAG[1] })
O.flat(c, c:rect(14, 12, 18, 13), SLAG[4], "fingers") O.dots(c, { { 14, 13 }, { 16, 13 }, { 18, 13 } }, SLAG[3])
-- the other hand resting on its tummy
local arm2, an2 = O.tube({ { 42, 34 }, { 44, 38 }, { 41, 42 }, { 38, 42 } }, function(t) return 1.7 - .3 * t end)
O.shadeN(c, arm2, an2, SLAG, { amb = .35, wrap = .45, sep = SLAG[2] })

-- face: calm, patient
c:eyeLocked(25, 32)
c:eyeLocked(35, 32)
c:cheek(22, 39) c:cheek(41, 39)
O.dots(c, { { 29, 40 }, { 30, 41 }, { 31, 41 }, { 32, 41 }, { 33, 41 }, { 34, 40 } }, P.ink)

-- the droplet that has only just let go
local drop = c:ellipse(32, 52, 1.2, 1.3)
O.shade(c, drop, SLAG, { R = 1, amb = .4, wrap = .5, cuts = { .1, .2, .4, .65, .85 } })

-- ripple rings in the puddle
O.mark(c, { { 26, 59 }, { 27, 59 }, { 37, 59 }, { 38, 59 } }, SLAG[2]) O.mark(c, { { 31, 58 }, { 32, 58 }, { 33, 58 } }, SLAG[6])

O.done(c, "pl-cwy-2-yard", function(c)
  -- heat shimmer off the beam, and a spark ticking off the puddle
  for _, p in ipairs({ { 12, 2 }, { 13, 1 }, { 50, 2 }, { 51, 1 } }) do c:put(p[1], p[2], SLAG[4]) end
  for _, p in ipairs({ { 21, 57 }, { 20, 56 }, { 43, 57 }, { 44, 56 } }) do c:put(p[1], p[2], SLAG[5]) end
end)
