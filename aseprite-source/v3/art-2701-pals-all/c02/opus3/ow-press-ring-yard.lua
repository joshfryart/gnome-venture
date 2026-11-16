-- Press Ring (ow-press-ring), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c02/opus3), built on opus2.
-- Seedkeeper, uncommon, Olivewhistle. "A stone hoop that squeezes the most golden oil in town."
-- An upright olive-press millstone: a thick warm-granite hoop with the hole set high, so the heavy lower rim
-- carries the face; two round stone nubs on top (double knob); a chunky oak press lever runs through the hole
-- and out past the rim to the upper right. Uncommon touch: mica flecks, chisel marks, a worn lit rim.
-- Fix vs Haiku: the lever was faint against the stone and the drip a single pixel; now the lever is a 4 px oak
-- beam in warm browns (clearly not stone) seen through the hole, and the oil is a real gold drip and drop.
-- Richness (opus3): the hole now shows its bore (inner wall dark at the top-left, lit at the lower-right) so it reads
-- as a deep stone tube with the lever passing through; dressed millstone furrows radiate across the face (kept off
-- the eyes), granite flecks light and dark, an oil-soaked darker patch round the run, lever grain with a lit edge,
-- end-grain rings at the tip and rivets on the iron band, a lit wet bead on the puddle.
-- closer look: a green olive leaf caught in a furrow on the left rim (from today's pressing).
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
local pud = c:ellipse(37, 58.5, 4, 0.8)
O.flat(c, pud, OIL[3], "puddle")
O.dots(c, { { 35, 58 }, { 36, 58 } }, OIL[5]) O.dots(c, { { 39, 59 }, { 40, 59 } }, OIL[2]) O.dot(c, 34, 59, OIL[4])

-- lever behind the stone: from inside the hole out past the rim, upper right
local lev = c:line({ { 26, 28 }, { 56, 7 } }, 4)
local lb = {}
lev:each(function(x, y) if (x + 2 * y) % 7 == 0 then lb[K(x, y)] = -1 end end) -- grain
local lI, lT = O.shade(c, lev, WOOD, { R = 2, bias = lb, amb = .25, wrap = .35, sep = WOOD[1], rim = true, bounce = "#6a5a7a", bmax = 2 })
O.tex(c, lI, lT, WOOD, function(x, y, i) if (x + 2 * y) % 7 == 3 and i >= 3 and H(x, y, 2) > .4 then return 1 end end)
-- iron band near the end
O.retone(c, lI, lT, { "#2e2e3a", "#45465a", "#62647a", "#868aa0", "#aeb2c4", "#cfd3de" }, function(x, y, i)
  local t = (x - 26) / 30
  return t > .78 and t < .86
end)
O.dots(c, { { 50, 10 }, { 52, 12 } }, "#cfd3de") -- rivets
-- end grain at the tip
O.dots(c, { { 56, 7 }, { 55, 6 }, { 57, 8 } }, WOOD[5]) O.dot(c, 56, 7, WOOD[3])

-- stone hoop with the hole set high
local ring = c:ellipse(30, 33, 19, 18)
local hole = c:ellipse(30, 26, 6.5, 6)
ring:cut(hole)
-- the bore: inner wall seen through the hole, where the lever does not cover it
local bore = hole:copy() bore:cut(lev)
local BORE = { "#1e1a26", "#2e2834", "#4a4048", "#685c5e" }
local bmask = HP.mask()
bore:each(function(x, y)
  local u = (x - 30) + (y - 26) -- lower-right inner wall faces the light
  local col = (u > 5 and BORE[4]) or (u > 1 and BORE[3]) or (u > -4 and BORE[2]) or BORE[1]
  c:put(x, y, col, { r = { name = "bore" } })
end)
-- two round knobs on top
local k1, k2 = c:ellipse(21, 15.5, 3.5, 3), c:ellipse(39, 15.5, 3.5, 3)
local rb = {}
ring:each(function(x, y)
  rb[K(x, y)] = -1 -- weathered, mid-tone face so the cream eyes pop
  if y > 48 then rb[K(x, y)] = -2 end
  -- chisel marks: short diagonal ticks
  if (x * 5 + y * 3) % 23 == 0 and y > 20 then rb[K(x, y)] = -2 end
  -- dressed furrows: radial grooves from the hole, off the face
  local a = math.atan(y - 26, x - 30)
  local face = x >= 17 and x <= 44 and y >= 34 and y <= 47
  if not face and math.abs(((a * 8 / math.pi) % 1) - .5) < .07 then rb[K(x, y)] = -2 end
  -- oil-soaked patch round the run
  if x >= 30 and x <= 34 and y >= 45 and y <= 51 then rb[K(x, y)] = -2 end
end)
for _, k in ipairs({ k1, k2 }) do O.shade(c, k, STN, { R = 2, amb = .25, wrap = .35, rim = true }) end
local sI, sT = O.shade(c, ring, STN, { R = 5, bias = rb, amb = .22, wrap = .35, rim = true, bounce = "#6a7aa0", bmax = 2, sep = STN[2] })
-- mica / feldspar flecks
O.tex(c, sI, sT, STN, function(x, y, i)
  if H(x, y, 12) > .95 and i >= 2 and i <= 5 then return 1 end
  if H(x, y, 14) > .93 and i >= 3 then return -1 end
end)
-- the lit lip of the bore (top edge of the lower rim catches light)
for x = 25, 35 do local y = 32 if ring:has(x, y) and not ring:has(x, y - 1) and not lev:has(x, y - 1) then O.mark(c, { { x, y } }, STN[6]) end end
-- closer look: an olive leaf caught in a furrow on the left rim
O.dots(c, { { 14, 30 }, { 15, 29 }, { 16, 29 }, { 15, 30 }, { 16, 28 } }, "#5f8a3c") O.dots(c, { { 15, 29 }, { 16, 28 }, { 17, 28 } }, "#a8c870") O.dot(c, 13, 31, "#3b5124")

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
-- the fat drop hanging off the rim, about to fall
O.flat(c, c:rect(31, 51, 33, 53), OIL[3], "drop") O.dot(c, 31, 51, OIL[5]) O.dots(c, { { 33, 53 }, { 32, 53 } }, OIL[2])

O.shift(c, -3, 0)
O.done(c, "ow-press-ring-yard")
