-- Mirage Moon (dw-mirage-moon), yard sprite 64x64. Opus richness pass (c04/opus3), built on c04/opus2.
-- Richness pass: ringed craters (dark upper-left wall, lit lower-right lip) and soft maria on the moon, hue-shifted
-- 6-tone ramps, wind ripples on the dune, a woven saddle blanket with a tasselled fringe and hump fuzz on the camel.
-- Fixed from opus2: the camel blink was a 2 px line; now a bigger head with a squeezed-shut curved eye, a lash and
-- three blink ticks above it. Closer look: a little wayfinder star hangs on a thread from the moon's right horn.
-- Wayfinder, rare, Dunewhisper. "Shines over the dunes and makes the camels blink."
-- A cradle moon floating over a dune: honey-cream crescent with lavender night shading, horns up, the face on
-- the thick belly of the crescent, a few soft crater flecks, a glow of two sparkles, heat-shimmer dashes below.
-- Fixed from Haiku: the thin side-on crescent left no room for the face (eyes squeezed on the horn) and the
-- gold orb floating above read as a stray coin. The cradle shape gives the face a wide, calm band.
-- quirk: a little camel on the dune below, eyes squeezed shut in a blink (dazzled by the moon).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-mirage-moon-yard", 64)

local MOON  = { "#4a3a6e", "#7a5a8e", "#b4849a", "#e0b07e", "#f2d48e", "#fbeec0" }
local DUNE  = { "#6e3e42", "#a0644a", "#cc8e50", "#e6b66a", "#f5d494", "#fbe8b8" }
local CAMEL = { "#43242a", "#743f30", "#a46a3c", "#c99458", "#e3b878", "#f4d8a0" }
local BLAN  = { "#4a1a3a", "#7a2a44", "#b43c48", "#e0644a" }
local GOLD  = { "#8a5a1e", "#d49a2e", "#f5c84a", "#fff0a8" }
local SHIM  = "#c9b4e0"

-- the cradle moon
local CX = 27
local moon = c:ellipse(CX, 29, 21.5, 21.5)
moon:cut(c:ellipse(CX, 13.5, 20.5, 20.5))
local bias = {}
moon:each(function(x, y) if x - CX + (y - 30) * .6 > 14 then bias[K(x, y)] = -1 end end)
local mI, mT = O.shade(c, moon, MOON, { R = 6, bias = bias, amb = .2, wrap = .35, rim = true, bounce = "#8a7ab8", bmax = 3 })
-- soft craters on the lit face, kept off the face band
O.tex(c, mI, mT, MOON, function(x, y, i)
  local face = y > 37 and y < 49 and math.abs(x - CX) < 14
  if face then return end
  if H(x, y, 31) > .93 and i >= 3 then return -1 end
end)
-- soft maria (low-frequency darker patches) on the lit side
O.tex(c, mI, mT, MOON, function(x, y, i)
  local face = y > 36 and y < 50 and math.abs(x - CX) < 15
  if not face and i >= 5 and O.H(x // 4, y // 3, 7) > .62 then return -1 end
end)
-- ringed craters: dark upper-left wall, lit lower-right lip
for _, cr in ipairs({ { 9, 32, 2 }, { 40, 36, 1 }, { 13, 25, 1 }, { 44, 28, 1 }, { 22, 52, 1 } }) do
  local x, y, r = cr[1], cr[2], cr[3]
  if r == 2 then
    O.mark(c, { { x, y - 1 }, { x + 1, y - 1 }, { x - 1, y }, { x - 1, y + 1 } }, MOON[3])
    O.mark(c, { { x, y }, { x + 1, y }, { x, y + 1 } }, MOON[4])
    O.mark(c, { { x + 2, y }, { x + 2, y + 1 }, { x, y + 2 }, { x + 1, y + 2 } }, MOON[6])
  else
    O.mark(c, { { x, y }, { x + 1, y } }, MOON[3])
    O.mark(c, { { x, y + 1 }, { x + 1, y + 1 } }, MOON[6])
  end
end
-- closer look: a little wayfinder star on a thread from the left horn
local star = c:poly{ { 53.5, 24 }, { 55.1, 26.4 }, { 57.6, 26.6 }, { 56, 28.4 }, { 56.6, 31 }, { 53.7, 29.6 }, { 50.8, 31 }, { 51.4, 28.4 }, { 49.6, 26.6 }, { 52.1, 26.4 } }
O.shade(c, star, GOLD, { R = 1, amb = .4, wrap = .5, cuts = { .3, .6, .85 } })

-- face on the belly
c:eyeLocked(18, 38)
c:eyeLocked(32, 38)
c:cheek(15, 44) c:cheek(38, 44)
O.dots(c, { { 24, 44 }, { 25, 45 }, { 26, 45 }, { 27, 45 }, { 28, 45 }, { 29, 44 } }, P.ink)

-- move the moon up-left so the camel stands clear of its lower horn, then the dune and camel in front
O.shift(c, -2, -2)

-- dune with the camel on it (back plane, drawn first)
local dune = c:ellipse(47, 63, 17, 6)
dune:cut(c:rect(0, 61, 63, 70)) dune:cut(c:rect(62, 0, 70, 70))
local dI, dT = O.shade(c, dune, DUNE, { R = 3, amb = .3, wrap = .4, cuts = O.CUTS })
O.tex(c, dI, dT, DUNE, function(x, y, i) if (math.floor(x * .45) + y) % 3 == 0 and i >= 3 and y > 58 then return -1 end end) -- wind ripples

-- camel: body, hump, neck, head, legs (small, side-on, facing left toward the moon)
local legs = HP.mask()
for _, lx in ipairs({ 51, 53, 57, 59 }) do legs:add(c:rect(lx, 53, lx, 58)) end
O.flat(c, legs, CAMEL[2], "legs")
local cb = c:ellipse(55, 51, 5, 2.8)
cb:add(c:ellipse(55.5, 47.5, 2.6, 2.4))
local neck = O.tube({ { 52, 50 }, { 51, 48 }, { 50.5, 46 }, { 50.5, 44 } }, function() return 1.2 end)
cb:add(neck)
cb:add(c:ellipse(49, 43, 3.2, 2.2))
cb:add(c:ellipse(46.5, 44.2, 1.6, 1.3)) -- muzzle
cb:add(c:rect(51, 40, 51, 40)) -- ear
local cI, cT = O.shade(c, cb, CAMEL, { R = 2, amb = .2, wrap = .35, sep = CAMEL[1], cuts = { .3, .5, .68, .84, .96 } })
O.tex(c, cI, cT, CAMEL, function(x, y, i) if y <= 47 and x >= 54 and (x + y) % 2 == 0 and i >= 4 then return 1 end end) -- hump fuzz
O.dots(c, { { 60, 50 }, { 61, 51 } }, CAMEL[2]) O.dot(c, 61, 52, CAMEL[1]) -- tail tuft
-- woven saddle blanket with a tasselled fringe
local bl = c:rect(53, 49, 58, 52)
local blI, blT = O.shade(c, bl, BLAN, { R = 1, amb = .35, wrap = .4, cuts = { .3, .6, .82 }, sep = CAMEL[1] })
O.dots(c, { { 53, 50 }, { 55, 50 }, { 57, 50 } }, GOLD[3])
O.dots(c, { { 54, 50 }, { 56, 50 }, { 58, 50 } }, GOLD[2])
O.dots(c, { { 53, 53 }, { 55, 53 }, { 57, 53 } }, GOLD[3])
-- the blink: a squeezed-shut curved eye with a lash
O.dots(c, { { 47, 42 }, { 48, 43 }, { 49, 43 }, { 50, 42 } }, P.ink)
O.dot(c, 46, 41, P.ink)
O.dots(c, { { 48, 42 }, { 49, 42 } }, CAMEL[3])
O.dots(c, { { 45, 44 } }, CAMEL[1]) -- nostril
O.dots(c, { { 46, 46 }, { 47, 46 } }, CAMEL[2]) -- mouth

O.shift(c, 0, -1)
O.done(c, "dw-mirage-moon-yard", function(c)
  -- glow sparkles and heat shimmer (not outlined)
  c:sparkle(14, 6) c:sparkle(57, 6)
  -- blink ticks above the camel's squeezed eye
  for _, t in ipairs({ { 45, 37 }, { 46, 38 }, { 48, 36 }, { 48, 37 }, { 51, 36 }, { 50, 37 } }) do c:put(t[1], t[2], "#fbeec0") end
  -- the star's thread (thin, not outlined)
  for _, t in ipairs({ { 46, 15 }, { 47, 15 }, { 48, 16 }, { 49, 17 }, { 50, 18 }, { 51, 19 } }) do c:put(t[1], t[2], "#9a8ab0") end
  for _, d in ipairs({ { 6, 55, 4 }, { 13, 57, 5 }, { 4, 59, 3 }, { 20, 54, 3 } }) do
    for i = 0, d[3] - 1 do c:put(d[1] + i, d[2] + ((i % 3 == 1) and -1 or 0), SHIM) end
  end
end)
