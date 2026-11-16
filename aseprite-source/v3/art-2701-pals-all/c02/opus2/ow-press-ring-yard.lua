-- Press Ring (ow-press-ring), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Seedkeeper, uncommon, Olivewhistle. "A stone hoop that squeezes the most golden oil in town."
-- An upright olive-press millstone: a thick warm-granite hoop with the hole set high, so the heavy lower rim
-- carries the face; two round stone nubs on top (double knob); a chunky oak press lever runs through the hole
-- and out past the rim to the upper right. Uncommon touch: mica flecks, chisel marks, a worn lit rim.
-- Fix vs Haiku: the lever was faint against the stone and the drip a single pixel; now the lever is a 4 px oak
-- beam in warm browns (clearly not stone) seen through the hole, and the oil is a real gold drip and drop.
-- quirk: a run of golden oil drips from its lower lip, with a fat drop about to fall into a little gold puddle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-press-ring-yard", 64)

local STN  = { "#2e2834", "#4a4048", "#685c5e", "#8a7c76", "#ac9e90", "#cec2ac" }
local WOOD = { "#3e2420", "#62382a", "#8a5434", "#b07642", "#d29a5a", "#ecc184" }
local OIL  = { "#8a5a10", "#c08a18", "#e8b420", "#f8d84a", "#fff2a0" }

c:groundShadow(31, 57, 21, 2.5)
-- gold puddle on the ground (part of the quirk)
local pud = c:ellipse(35, 58.5, 4, 0.8)
O.flat(c, pud, OIL[3], "puddle")
O.dots(c, { { 33, 58 }, { 34, 58 } }, OIL[5]) O.dots(c, { { 37, 59 }, { 38, 59 } }, OIL[2])

-- lever behind the stone: from inside the hole out past the rim, upper right
local lev = c:line({ { 26, 28 }, { 56, 7 } }, 4)
local lb = {}
lev:each(function(x, y) if (x + 2 * y) % 7 == 0 then lb[K(x, y)] = -1 end end) -- grain
local lI, lT = O.shade(c, lev, WOOD, { R = 2, bias = lb, amb = .25, wrap = .35, sep = WOOD[1], rim = true })
-- iron band near the end
O.retone(c, lI, lT, { "#2e2e3a", "#45465a", "#62647a", "#868aa0", "#aeb2c4", "#cfd3de" }, function(x, y, i)
  local t = (x - 26) / 30
  return t > .78 and t < .86
end)

-- stone hoop with the hole set high
local ring = c:ellipse(30, 33, 19, 18)
local hole = c:ellipse(30, 26, 6.5, 6)
ring:cut(hole)
-- two round knobs on top
local k1, k2 = c:ellipse(21, 15.5, 3.5, 3), c:ellipse(39, 15.5, 3.5, 3)
local rb = {}
ring:each(function(x, y)
  if y > 48 then rb[K(x, y)] = -1 end
  -- chisel marks: short diagonal ticks
  if (x * 5 + y * 3) % 23 == 0 and y > 20 then rb[K(x, y)] = -1 end
end)
for _, k in ipairs({ k1, k2 }) do O.shade(c, k, STN, { R = 2, amb = .25, wrap = .35, rim = true }) end
local sI, sT = O.shade(c, ring, STN, { R = 5, bias = rb, amb = .22, wrap = .35, rim = true, bounce = "#6a7aa0", bmax = 2, sep = STN[2] })
-- mica / feldspar flecks
O.tex(c, sI, sT, STN, function(x, y, i) if H(x, y, 12) > .95 and i >= 2 and i <= 5 then return 1 end end)

-- face on the heavy lower rim
c:eyeLocked(21, 36)
c:eyeLocked(34, 36)
O.dots(c, { { 18, 43 }, { 19, 43 } }, "#f5809f") O.dots(c, { { 41, 43 }, { 42, 43 } }, "#f5809f")
-- content little smile
O.dots(c, { { 27, 44 }, { 28, 45 }, { 29, 45 }, { 30, 45 }, { 31, 45 }, { 32, 44 } }, P.ink)

-- quirk: golden oil running from the lower lip down the rim, a fat drop just leaving it
O.flat(c, c:rect(31, 46, 32, 50), OIL[3], "oil")
O.dots(c, { { 31, 46 }, { 31, 47 }, { 31, 48 } }, OIL[4])
O.dots(c, { { 32, 49 }, { 32, 50 } }, OIL[2])
-- the falling drop, clear of the rim
O.flat(c, c:rect(32, 54, 33, 55), OIL[3], "drop") O.dot(c, 32, 54, OIL[5]) O.dot(c, 33, 55, OIL[2])

O.shift(c, -3, 0)
O.done(c, "ow-press-ring-yard")
