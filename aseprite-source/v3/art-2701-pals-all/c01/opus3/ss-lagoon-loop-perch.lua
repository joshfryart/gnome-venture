-- Lagoon Loop (ss-lagoon-loop), perch sprite 36x36. Opus third pass (c01/opus3), richness pass over opus2:
-- a 2 px inner sand wall at the top of the hole (dark where it turns away, lit on the right) so the hole has depth,
-- water in bowl-following bands, toes and two wind ripples, the tiny crab from the yard on the right shoulder.
-- Sand ring with the hole pushed up so the thick lower band carries the pill eyes and smile; lagoon in two
-- water tones plus a foam line, a few sand flecks, one shell.
-- quirk: the palm islet, here a 3 px sand bar with a 2-leaf palm; the glint winks beside it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-lagoon-loop-perch", 36)

local SAND = { "#6e4038", "#a3663e", "#cf9450", "#e8bd6a", "#f4da94", "#fbf0c4" }
local SEA  = { "#1d3f63", "#22607e", "#2b8a9c", "#46b8b8", "#86dccc", "#cff4e4" }
local PALM = { "#2f7a46", "#58a850", "#94d066" }

c:groundShadow(18, 32, 12, 1.5)
for _, fx in ipairs({ 13, 23 }) do O.shade(c, c:ellipse(fx, 30, 2.5, 1.5), SAND, { R = 1, amb = .25, sep = SAND[1] }) end
local outer = c:ellipse(18, 17, 13, 12.5)
local hole = c:ellipse(18, 13.5, 6.5, 5.5)
local ring = outer:copy():cut(hole)
local rb = {}
ring:each(function(x, y) if hole:has(x, y - 1) then rb[K(x, y)] = -1 end end)
local rI, rT = O.shade(c, ring, SAND, { R = 4, bias = rb, amb = .06, wrap = .28, sep = SAND[1], rim = true, bounce = "#6f9ab0", bmax = 2 })
O.tex(c, rI, rT, SAND, function(x, y, i)
  if y > 19 and y < 28 and x > 10 and x < 26 then return end
  local h = H(x, y, 7)
  if h > .9 and i >= 2 and i <= 5 then return 1 end
  if h < .05 and i >= 3 then return -1 end
end)
O.dots(c, { { 8, 12 }, { 9, 12 } }, "#f7a8a8") O.dot(c, 8, 13, "#c94f6d")
for _, fx in ipairs({ 13, 23 }) do O.mark(c, { { fx, 31 } }, SAND[2]) end
O.mark(c, { { 7, 17 }, { 7, 18 }, { 28, 9 }, { 29, 10 } }, SAND[3]) O.mark(c, { { 8, 16 }, { 27, 8 } }, SAND[5])
-- the crab on the right shoulder
O.flat(c, c:rect(28, 6, 29, 7), "#e05a3a", "crab") O.dot(c, 28, 6, "#f8905a") O.dots(c, { { 27, 5 }, { 30, 5 } }, "#e05a3a")

local water = hole:copy():clip(hole:shift(0, 2))
hole:each(function(x, y)
  if not water:has(x, y) then
    c:put(x, y, (x < 16) and SAND[2] or (x < 21 and SAND[3] or SAND[4]), rT)
  else
    local t = (y - 10) / 9 + .25 * ((x + .5 - 18) / 6.5) ^ 2
    local i = (not water:has(x, y - 1)) and 1 or (t < .25 and 2 or (t < .5 and 3 or (t < .75 and 4 or 5)))
    c:put(x, y, SEA[i], { r = { name = "sea" } })
  end
end)
hole:edge():each(function(x, y) if y > 15 then c:put(x, y, SEA[6], { r = { name = "foam" } }) end end)
-- islet + palm
O.dots(c, { { 15, 14 }, { 16, 14 }, { 17, 14 } }, SAND[5]) O.dots(c, { { 15, 15 }, { 16, 15 }, { 17, 15 } }, SEA[6])
O.dots(c, { { 16, 13 }, { 16, 12 }, { 17, 11 } }, "#7a4a34")
O.dots(c, { { 15, 10 }, { 16, 10 }, { 14, 11 } }, PALM[2]) O.dots(c, { { 18, 10 }, { 19, 11 } }, PALM[1]) O.dot(c, 17, 10, PALM[3])
-- glint
O.dots(c, { { 21, 12 }, { 20, 12 }, { 22, 12 }, { 21, 11 }, { 21, 13 } }, SEA[6]) O.dot(c, 21, 12, "#fdf6dc")
-- face
c:eyeSmall(13, 20)
c:eyeSmall(21, 20)
O.dot(c, 10, 23, P.petal.base) O.dot(c, 25, 23, P.petal.base)
O.dots(c, { { 16, 24 }, { 17, 25 }, { 18, 25 }, { 19, 24 } }, P.ink)
O.done(c, "ss-lagoon-loop-perch")
