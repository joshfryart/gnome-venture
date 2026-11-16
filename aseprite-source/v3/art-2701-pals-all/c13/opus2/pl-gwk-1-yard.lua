-- Fang Chip (pl-gwk-1), yard sprite 64x64. Opus second pass (c13/opus2), built on c13/haiku.
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

local IVORY = { "#5a3a30", "#8e6a4e", "#bf9e78", "#e2c99f", "#f4e5c4", "#fdf6e4" }
local ROOT  = { "#4a2c2c", "#74504a", "#9c7a68", "#bfa088", "#d8bea2", "#e8d4ba" }
local MOON  = { "#7a5a2a", "#c09a42", "#ecd070", "#fff0b0" }

c:groundShadow(30, 59, 9, 1.5)
-- the fang: a tapering curved tube, root up, tip down
local fang, fn = O.tube({ { 35, 18 }, { 39, 33 }, { 36, 47 }, { 23, 58 } }, function(t) return 11.5 * (1 - t) ^ .8 + .4 end)
-- the root above it: a narrower cone with a waist at the enamel line, so it reads as a tooth, not a blob
local root, rn = O.tube({ { 39, 5 }, { 38, 9 }, { 36, 13 }, { 35, 17 } }, function(t) return 2.5 + t * 5.5 end)
root:each(function(x, y) if not fang:has(x, y) then fang:set(x, y) fn[K(x, y)] = rn[K(x, y)] end end)
-- the chip: a notch out of the right edge near the tip
local chip = c:poly{ { 41, 40 }, { 34, 45 }, { 38, 49 }, { 44, 45 } }
fang:cut(chip)
local fI, fT = O.shadeN(c, fang, fn, IVORY, { amb = .3, wrap = .5, rim = true, bounce = "#8a8ab0", bmax = 3 })
-- root above the enamel line (wavy), enamel streaks lower down
O.tex(c, fI, fT, IVORY, function(x, y, i)
  local line = 15 + math.floor(math.sin(x * .5) * 1.2 + .5)
  if y < line then
    c.pix[y * c.w + x] = ROOT[math.max(1, i - 1)]
    return 0
  end
  if y == line then c.pix[y * c.w + x] = ROOT[math.max(1, i - 1)] return 0 end
  if y > 34 and (x * 2 + y) % 7 == 0 and i >= 3 and i <= 5 then return 1 end
end)
-- the broken face of the chip: dark rough edge along the cut, lit lip on top
chip:grow(1):each(function(x, y)
  local p = y * c.w + x
  if c.own[p] == fT and not chip:has(x, y) then
    c.pix[p] = (y < 45) and IVORY[6] or IVORY[2]
  end
end)

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
O.shade(c, moon, MOON, { sphere = { 8, 8, 8 }, amb = .35, wrap = .5, cuts = { .3, .55, .8 } })
O.done(c, "pl-gwk-1-yard", function(c)
  -- growl ticks off its right side: three short jagged marks
  for _, p in ipairs({ { 51, 20 }, { 52, 19 }, { 53, 20 }, { 54, 19 },
                       { 52, 25 }, { 53, 24 }, { 54, 25 }, { 55, 24 }, { 56, 25 },
                       { 51, 30 }, { 52, 29 }, { 53, 30 }, { 54, 29 } }) do c:put(p[1], p[2], P.ink) end
  c:sparkle(21, 4)
end)
