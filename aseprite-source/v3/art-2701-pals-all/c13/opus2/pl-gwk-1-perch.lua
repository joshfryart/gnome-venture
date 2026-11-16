-- Fang Chip (pl-gwk-1), perch sprite 36x36. Opus second pass (c13/opus2), hand-built at this size.
-- Curved ivory wolf canine balancing on its point, narrower dusky root above the enamel line, the chip notched out
-- of the right edge near the tip. 2x3 pill eyes under cross brows, a wavy growl.
-- quirk: the moon is out: a small crescent at the top left, two growl ticks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-1-perch", 36)

local IVORY = { "#5a3a30", "#8e6a4e", "#bf9e78", "#e2c99f", "#f4e5c4", "#fdf6e4" }
local ROOT  = { "#4a2c2c", "#74504a", "#9c7a68", "#bfa088", "#d8bea2", "#e8d4ba" }
local MOON  = { "#7a5a2a", "#c09a42", "#ecd070", "#fff0b0" }

c:groundShadow(16, 33, 6, 1)
local fang, fn = O.tube({ { 20, 11 }, { 24, 20 }, { 22, 27 }, { 13, 32 } }, function(t) return 8.5 * (1 - t) ^ .8 + .3 end)
local root, rn = O.tube({ { 22, 2 }, { 21, 5 }, { 20, 8 }, { 20, 11 } }, function(t) return 2.5 + t * 3.5 end)
root:each(function(x, y) if not fang:has(x, y) then fang:set(x, y) fn[K(x, y)] = rn[K(x, y)] end end)
local chip = c:poly{ { 26, 22 }, { 21, 25 }, { 23, 28 }, { 28, 25 } }
fang:cut(chip)
local fI, fT = O.shadeN(c, fang, fn, IVORY, { amb = .3, wrap = .5, rim = true, bounce = "#8a8ab0", bmax = 3 })
O.tex(c, fI, fT, IVORY, function(x, y, i)
  local line = 9 + ((x % 4 < 2) and 0 or 1)
  if y < line then c.pix[y * c.w + x] = ROOT[i] return 0 end
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
O.shade(c, moon, MOON, { sphere = { 4, 4, 5 }, amb = .35, wrap = .5, cuts = { .3, .55, .8 } })
O.done(c, "pl-gwk-1-perch", function(c)
  for _, p in ipairs({ { 29, 12 }, { 30, 11 }, { 31, 12 }, { 32, 11 }, { 30, 16 }, { 31, 15 }, { 32, 16 }, { 33, 15 } }) do c:put(p[1], p[2], P.ink) end
end)
