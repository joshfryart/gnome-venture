-- Mirage Moon (dw-mirage-moon), yard sprite 64x64. Opus second pass (art-2701-pals-all/c04/opus2), from the Haiku pass.
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
local DUNE  = { "#7a4a3a", "#a86a44", "#d0924e", "#e8b868", "#f5d494" }
local CAMEL = { "#4a2a24", "#7a4a30", "#a8703e", "#c99458", "#e3b878" }
local SHIM  = "#c9b4e0"

-- dune with the camel on it (back plane, drawn first)
local dune = c:ellipse(47, 63, 17, 6)
dune:cut(c:rect(0, 61, 63, 70)) dune:cut(c:rect(62, 0, 70, 70))
O.shade(c, dune, DUNE, { R = 3, amb = .3, wrap = .4, cuts = { .3, .5, .7, .85 } })

-- camel: body, hump, neck, head, legs (small, side-on, facing left toward the moon)
local legs = HP.mask()
for _, lx in ipairs({ 51, 53, 57, 59 }) do legs:add(c:rect(lx, 53, lx, 58)) end
O.flat(c, legs, CAMEL[2], "legs")
local cb = c:ellipse(55, 51, 5, 2.8)
cb:add(c:ellipse(55.5, 47.5, 2.6, 2.4))
local neck = O.tube({ { 52, 50 }, { 51, 48 }, { 50.5, 46 }, { 50.5, 44 } }, function() return 1.2 end)
cb:add(neck)
cb:add(c:ellipse(49.5, 43, 2.5, 1.6))
O.shade(c, cb, CAMEL, { R = 2, amb = .25, wrap = .4, sep = CAMEL[1], cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 60, 50 }, { 61, 51 } }, CAMEL[2]) -- tail
O.dots(c, { { 48, 42 }, { 49, 42 } }, P.ink)  -- closed eye: a blink
O.dots(c, { { 48, 41 }, { 49, 41 } }, CAMEL[5])
O.dot(c, 47, 44, CAMEL[1])

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
for _, cr in ipairs({ { 9, 31 }, { 42, 34 }, { 12, 23 } }) do
  O.mark(c, { { cr[1], cr[2] }, { cr[1] + 1, cr[2] } }, MOON[3])
  O.mark(c, { { cr[1], cr[2] + 1 }, { cr[1] + 1, cr[2] + 1 } }, MOON[5])
end

-- face on the belly
c:eyeLocked(18, 38)
c:eyeLocked(32, 38)
c:cheek(15, 44) c:cheek(38, 44)
O.dots(c, { { 24, 44 }, { 25, 45 }, { 26, 45 }, { 27, 45 }, { 28, 45 }, { 29, 44 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "dw-mirage-moon-yard", function(c)
  -- glow sparkles and heat shimmer (not outlined)
  c:sparkle(7, 9) c:sparkle(57, 6)
  for _, d in ipairs({ { 6, 55, 4 }, { 13, 57, 5 }, { 4, 59, 3 }, { 20, 54, 3 } }) do
    for i = 0, d[3] - 1 do c:put(d[1] + i, d[2] + ((i % 3 == 1) and -1 or 0), SHIM) end
  end
end)
