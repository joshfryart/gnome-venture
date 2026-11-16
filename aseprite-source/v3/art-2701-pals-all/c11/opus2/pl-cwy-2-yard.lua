-- Slag Drip (pl-cwy-2), yard sprite 64x64. Opus second pass (c11/opus2), built on c11/haiku.
-- Seedkeeper, common, Forge of the Cinder Wyrm. "A thick glowing drip that takes its time falling off the forge."
-- haiku drew a red flask under a grey cap (read as a potion bottle). Now the drip hangs from a dark riveted iron
-- forge lip: a thick molten neck stretching into a heavy glowing bulb (white-hot core, orange body, red base),
-- with patches of cooling dark crust on the neck and a small puddle glowing on the floor below.
-- quirk: it takes its time: one little molten hand still holding the forge lip, a calm smile, and a tiny droplet
-- that has only just let go.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-2-yard", 64)

local SLAG = { "#6a1a1e", "#a82c1c", "#e05a1e", "#f8962e", "#ffcc56", "#fff0a0" }
local CRST = { "#2a1a1e", "#44282a", "#643a30" }
local IRON = { "#1a1822", "#2a2632", "#3e3848", "#585060", "#7c7484", "#a49caa" }

-- glowing puddle on the floor
local pud = c:ellipse(32, 59, 9, 1.5)
O.shade(c, pud, SLAG, { R = 1, amb = .3, wrap = .4, cuts = { .2, .4, .6, .8, .95 } })

-- the forge lip: a thick riveted iron beam
local beam = c:rrect(4, 4, 59, 13, 2)
local iI, iT = O.shade(c, beam, IRON, { R = 3, amb = .25, wrap = .4, rim = true })
O.tex(c, iI, iT, IRON, function(x, y, i) if H(x, y, 9) > .88 then return -1 end end)
for x = 4, 59 do O.mark(c, { { x, 11 } }, IRON[2]) end -- bottom chamfer
for _, rx in ipairs({ 9, 20, 44, 54 }) do
  O.dots(c, { { rx, 7 }, { rx + 1, 7 }, { rx, 8 }, { rx + 1, 8 } }, IRON[3]) O.dot(c, rx, 7, IRON[6])
end
-- hot slag sitting along the lip edge
for x = 22, 42 do if x % 4 ~= 1 then O.mark(c, { { x, 13 } }, SLAG[2]) end end

-- the drip: neck stretching down to a heavy bulb
local drip, dn = O.tube({ { 32, 13 }, { 31, 20 }, { 33, 26 }, { 32, 32 } }, function(t) return 4.5 + 2 * t end)
drip:add(c:ellipse(32, 39, 13, 11.5))
drip:add(c:ellipse(32, 15, 7, 3)) -- where it pools under the lip
drip:clip(c:rect(0, 12, 63, 63))
local dI, dT = O.shade(c, drip, SLAG, { sphere = { 28, 32, 18 }, amb = .3, wrap = .45, rim = true })
-- white-hot core, red sinking to the base
O.flat(c, c:ellipse(28, 34, 3, 2), SLAG[6], "core")
drip:each(function(x, y)
  local q = y * c.w + x
  if c.own[q] == dT and y >= 47 and (x + y) % 2 == 0 then c.pix[q] = SLAG[2] end
end)
-- cooling crust patches on the neck
for _, p in ipairs({ { 29, 16, 3, 1 }, { 34, 20, 2, 1 }, { 30, 24, 1, 1 }, { 36, 15, 2, 1 } }) do
  local m = c:ellipse(p[1], p[2], p[3], p[4]) m:clip(drip)
  m:each(function(x, y) O.mark(c, { { x, y } }, (x + y) % 3 == 0 and CRST[3] or CRST[2]) end)
end
-- surface flow streaks
for _, s in ipairs({ { 38, 30 }, { 40, 34 }, { 41, 38 }, { 24, 41 }, { 25, 44 } }) do O.mark(c, { s, { s[1], s[2] + 1 } }, SLAG[4]) end

-- quirk: a little molten hand still holding the forge lip
local arm, an = O.tube({ { 22, 30 }, { 17, 26 }, { 15, 20 }, { 16, 14 } }, function(t) return 1.9 - .3 * t end)
O.shadeN(c, arm, an, SLAG, { amb = .35, wrap = .45, sep = SLAG[1] })
O.flat(c, c:rect(14, 12, 18, 13), SLAG[4], "fingers") O.dots(c, { { 14, 12 }, { 16, 12 }, { 18, 12 } }, SLAG[5])
-- the other hand resting on its tummy
local arm2, an2 = O.tube({ { 42, 36 }, { 44, 40 }, { 41, 44 }, { 38, 44 } }, function(t) return 1.7 - .3 * t end)
O.shadeN(c, arm2, an2, SLAG, { amb = .35, wrap = .45, sep = SLAG[2] })

-- face: calm, patient
c:eyeLocked(25, 34)
c:eyeLocked(35, 34)
c:cheek(22, 41) c:cheek(41, 41)
O.dots(c, { { 29, 42 }, { 30, 43 }, { 31, 43 }, { 32, 43 }, { 33, 43 }, { 34, 42 } }, P.ink)

-- the droplet that has only just let go
local drop = c:ellipse(32, 54.5, 1.5, 2)
O.shade(c, drop, SLAG, { R = 1, amb = .4, wrap = .5, cuts = { .1, .2, .4, .65, .85 } })

O.done(c, "pl-cwy-2-yard", function(c)
  -- heat shimmer off the beam, and a spark ticking off the puddle
  for _, p in ipairs({ { 12, 1 }, { 13, 0 }, { 50, 1 }, { 51, 0 } }) do c:put(p[1], p[2], SLAG[4]) end
  for _, p in ipairs({ { 22, 56 }, { 21, 55 }, { 42, 56 }, { 43, 55 } }) do c:put(p[1], p[2], SLAG[5]) end
end)
