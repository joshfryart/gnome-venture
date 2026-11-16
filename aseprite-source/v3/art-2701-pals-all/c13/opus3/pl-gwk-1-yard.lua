-- Fang Chip (pl-gwk-1), yard sprite 64x64. Opus richness pass (c13/opus3), built on c13/opus2.
-- opus3: opus2's dusky root read as a cap. The root is now a long amber cone tapering to a blunt apex with a tiny
-- dark canal dot, lengthwise cementum striations, and the enamel line bowed up in the middle (a real tooth neck,
-- not a hat brim); lighter warm ramp so it reads as more tooth. Enamel ramp hue-shifted (plum shadow to cool
-- pearl top), hairline craze cracks off the chip, crater flecks on the moon.
-- closer-look: the shine on the enamel is a tiny crescent moon of its own.
-- Thornblade, common, Lair of the Grey Wolf King. "A chipped wolf fang that only growls when the moon is out."
-- Haiku weakness fixed: a flat beige triangle (read as a pizza slice / carrot) with a dotted mouth. Now a real wolf
-- canine: a curved ivory crown tapering to a point that it balances on, a warmer root above an enamel line, faint
-- enamel streaks, and the chip taken clean out of the right edge near the tip (dark broken face, lit lip).
-- Face on the wide upper crown: cross brows and a wavy growl with one tiny fang of its own.
-- quirk: the moon is out, so it growls: a small crescent moon at the top left and "grr" growl ticks off its side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-1-yard", 64)

local IVORY = { "#4e3440", "#86645a", "#b8987a", "#dec8a2", "#f2e6c8", "#fbf6ea" }
local ROOT  = { "#5a3a2c", "#8e6648", "#bc9468", "#dcbc88", "#ecd4a4", "#f6e6c0" }
local MOON  = { "#7a4e2e", "#c0903e", "#ecc862", "#fbeaa8" }

c:groundShadow(30, 59, 9, 1.5)
-- the whole tooth as ONE continuous spindle (no step at the neck, so the root can't read as a cap): the root
-- tapers up from the widest point to a blunt apex, the crown tapers down to the point it balances on
local NECK = .3
local fang, fn, FT = O.tube({ { 37, 1 }, { 36, 22 }, { 40, 42 }, { 23, 58 } }, function(t)
  if t < NECK then return 2 + (t / NECK) ^ .6 * 9.8 end
  return 11.8 * ((1 - t) / (1 - NECK)) ^ .85 + .4
end)
-- the chip: a notch out of the right edge near the tip
local chip = c:poly{ { 41, 40 }, { 34, 45 }, { 38, 49 }, { 44, 45 } }
fang:cut(chip)
local fI, fT = O.shadeN(c, fang, fn, IVORY, { amb = .3, wrap = .5, rim = true, bounce = "#8a8ab0", bmax = 3 })
-- root above the enamel line (wavy), enamel streaks lower down
O.tex(c, fI, fT, IVORY, function(x, y, i)
  -- tooth neck: bowed up in the middle (convex towards the root)
  local t = FT[K(x, y)] or 1
  local line = 16 - math.floor((x - 37) * .3 + .5) + ((x % 5 == 0) and 1 or 0)
  if y < line then
    t = i
    if O.H(x, y, 3) > .82 and t >= 3 then t = t - 1 end -- worn cementum flecks
    if x == 38 - (y // 6) and y >= 3 and y <= line - 3 and t >= 2 then t = t - 1 end -- the root's long groove
    c.pix[y * c.w + x] = ROOT[t]
    return 0
  end
  if y == line then c.pix[y * c.w + x] = ROOT[math.max(1, i - 2)] return 0 end
  if y > 34 and (x * 2 + y) % 7 == 0 and i >= 3 and i <= 5 then return 1 end
end)
-- the broken face of the chip: dark rough edge along the cut, lit lip on top
chip:grow(1):each(function(x, y)
  local p = y * c.w + x
  if c.own[p] == fT and not chip:has(x, y) then
    c.pix[p] = (y < 45) and IVORY[6] or IVORY[2]
  end
end)

-- root apex: the tiny canal opening
O.mark(c, { { 37, 1 } }, ROOT[2])
-- hairline craze cracks running up from the chip
O.mark(c, { { 40, 39 }, { 41, 38 }, { 41, 37 }, { 42, 36 }, { 36, 44 }, { 35, 43 } }, IVORY[3])
-- closer-look: the enamel shine is a tiny crescent moon
O.mark(c, { { 27, 37 }, { 26, 38 }, { 26, 39 }, { 26, 40 }, { 27, 41 }, { 28, 41 } }, IVORY[6])
O.mark(c, { { 27, 38 }, { 27, 40 } }, IVORY[5])
-- face: cross little brows, growl
c:eyeLocked(28, 21)
c:eyeLocked(38, 21)
O.dots(c, { { 27, 18 }, { 28, 18 }, { 29, 19 }, { 30, 19 }, { 31, 20 } }, P.ink)
O.dots(c, { { 43, 18 }, { 42, 18 }, { 41, 19 }, { 40, 19 }, { 39, 20 } }, P.ink)
c:cheek(26, 28) c:cheek(43, 28)
-- wavy growl mouth with one tiny fang
O.dots(c, { { 31, 31 }, { 32, 30 }, { 33, 31 }, { 34, 32 }, { 35, 31 }, { 36, 30 }, { 37, 31 }, { 38, 32 }, { 39, 31 } }, P.ink)
O.dots(c, { { 33, 32 }, { 33, 33 } }, IVORY[6]) O.dot(c, 34, 33, P.ink) O.dot(c, 32, 33, P.ink) O.dot(c, 33, 34, P.ink)

O.shift(c, 0, 0)
-- the moon (drawn on top later as its own outlined part)
local moon = c:ellipse(11, 11, 6, 6)
moon:cut(c:ellipse(15, 8, 5, 5))
local mI, mT = O.shade(c, moon, MOON, { sphere = { 8, 8, 8 }, amb = .35, wrap = .5, cuts = { .3, .55, .8 }, rim = true })
O.mark(c, { { 7, 13 }, { 9, 15 }, { 6, 9 } }, MOON[2])
O.done(c, "pl-gwk-1-yard", function(c)
  -- growl ticks off its right side: three short jagged marks
  for _, p in ipairs({ { 51, 20 }, { 52, 19 }, { 53, 20 }, { 54, 19 },
                       { 52, 25 }, { 53, 24 }, { 54, 25 }, { 55, 24 }, { 56, 25 },
                       { 51, 30 }, { 52, 29 }, { 53, 30 }, { 54, 29 } }) do c:put(p[1], p[2], P.ink) end
  c:sparkle(21, 4)
end)
