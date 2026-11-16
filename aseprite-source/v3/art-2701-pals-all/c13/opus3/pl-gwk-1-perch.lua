-- Fang Chip (pl-gwk-1), perch sprite 36x36. Opus richness pass (c13/opus3), hand-built at this size.
-- opus3: the root no longer reads as a cap: the tooth is one continuous spindle (root tapering up to a blunt apex,
-- crown down to the point), root only a shade warmer than the enamel with a tilted neck line. Hue-shifted ramps.
-- Curved ivory wolf canine balancing on its point, narrower dusky root above the enamel line, the chip notched out
-- of the right edge near the tip. 2x3 pill eyes under cross brows, a wavy growl.
-- quirk: the moon is out: a small crescent at the top left, two growl ticks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-1-perch", 36)

local IVORY = { "#4e3440", "#86645a", "#b8987a", "#dec8a2", "#f2e6c8", "#fbf6ea" }
local ROOT  = { "#5a3a2c", "#8e6648", "#bc9468", "#dcbc88", "#ecd4a4", "#f6e6c0" }
local MOON  = { "#7a4e2e", "#c0903e", "#ecc862", "#fbeaa8" }

c:groundShadow(16, 33, 6, 1)
local NECK = .28
local fang, fn = O.tube({ { 20, 1 }, { 20, 13 }, { 24, 23 }, { 13, 32 } }, function(t)
  if t < NECK then return 1.5 + (t / NECK) ^ .6 * 6.8 end
  return 8.3 * ((1 - t) / (1 - NECK)) ^ .85 + .3
end)
local chip = c:poly{ { 26, 22 }, { 21, 25 }, { 23, 28 }, { 28, 25 } }
fang:cut(chip)
local fI, fT = O.shadeN(c, fang, fn, IVORY, { amb = .3, wrap = .5, rim = true, bounce = "#8a8ab0", bmax = 3 })
O.tex(c, fI, fT, IVORY, function(x, y, i)
  local line = 9 - math.floor((x - 20) * .3 + .5)
  if y < line then c.pix[y * c.w + x] = ROOT[i] return 0 end
  if y == line then c.pix[y * c.w + x] = ROOT[math.max(1, i - 2)] return 0 end
end)

c:eyeSmall(15, 13)
c:eyeSmall(22, 13)
O.dots(c, { { 14, 11 }, { 15, 11 }, { 16, 12 } }, P.ink)
O.dots(c, { { 24, 11 }, { 23, 11 }, { 22, 12 } }, P.ink)
O.dot(c, 13, 17, P.petal.base) O.dot(c, 25, 17, P.petal.base)
O.dots(c, { { 16, 18 }, { 17, 17 }, { 18, 18 }, { 19, 17 }, { 20, 18 }, { 21, 17 }, { 22, 18 } }, P.ink)
O.dot(c, 18, 19, IVORY[6])

local moon = c:ellipse(6, 6, 4, 4)
moon:cut(c:ellipse(9, 4, 3.5, 3.5))
O.shade(c, moon, MOON, { sphere = { 4, 4, 5 }, amb = .35, wrap = .5, cuts = { .3, .55, .8 }, rim = true })
O.done(c, "pl-gwk-1-perch", function(c)
  for _, p in ipairs({ { 29, 12 }, { 30, 11 }, { 31, 12 }, { 32, 11 }, { 30, 16 }, { 31, 15 }, { 32, 16 }, { 33, 15 } }) do c:put(p[1], p[2], P.ink) end
end)
