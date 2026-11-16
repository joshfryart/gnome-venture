-- Parrot Pennant (gc-parrot-pennant), perch sprite 36x36. Opus richness pass (c04/opus3), hand-built at this size.
-- Richness pass: hue-shifted red, a green covert band under the yellow shoulder, two dark covert lines on each wing,
-- breast scallops, a lit beak ridge, bark grain with lit thorns, a rain drop on the crest. Fixed from opus2: the
-- pennant tail showed only 4 rows below the twig; the whole bird now sits 2 px higher on the branch and the tail is
-- a longer swallow-tail (8 rows below the twig, three clear bands with a dark seam, lit left half). From opus2:
-- front-on scarlet macaw on a thorny twig: round red head with 2x3 pill eyes and cheeks, a pale hooked beak with
-- a dark tip, blue wings with a yellow shoulder band, and a short red/yellow/blue striped pennant tail.
-- quirk: two sound arcs of its shout, the bigger one further out.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gc-parrot-pennant-perch", 36)

local RED  = { "#3e1430", "#6e1a2e", "#a82632", "#d8402e", "#f0703e", "#fbac6c" }
local BLUE = { "#1a2448", "#24407a", "#2f63a8", "#4a8fd0", "#7cbde8" }
local YEL  = { "#8a5a1a", "#c98a22", "#f0be38", "#fbe07a" }
local BEAK = { "#3a3442", "#6a6476", "#bcb6c4", "#e4e0ea" }
local BARK = { "#2e1e1c", "#4a3026", "#6e4a32", "#94683e", "#b88c56" }

-- tail pennant: long swallow-tail, three bands with dark seams, lit left half
local pen = c:poly{ { 14, 27 }, { 19, 27 }, { 25, 37.5 }, { 21.5, 34 }, { 18, 37.5 } }
pen:each(function(x, y)
  local lit = x < 18 + (y - 27) * .35
  local col
  if y <= 31 then col = lit and RED[4] or RED[3]
  elseif y == 32 then col = RED[2]
  elseif y <= 34 then col = lit and YEL[3] or YEL[2]
  elseif y == 35 then col = YEL[1]
  else col = lit and BLUE[4] or BLUE[3] end
  c:put(x, y, col, { r = { name = "pennant" } })
end)
-- branch
for x = 3, 32 do
  O.dot(c, x, 28, (x % 4 == 0) and BARK[3] or ((x % 4 == 2) and BARK[5] or BARK[4]))
  O.dot(c, x, 29, (x % 5 == 0) and BARK[1] or BARK[2])
end
O.dots(c, { { 6, 27 }, { 29, 27 } }, BARK[4]) O.dots(c, { { 6, 26 }, { 30, 26 } }, "#e6c890")

for _, w in ipairs({ 10.5, 23.5 }) do
  local wing = c:ellipse(w, 20, 3, 6)
  local _, wT = O.shade(c, wing, BLUE, { sphere = { w - 1, 17, 7 }, amb = .2, wrap = .4, sep = BLUE[1], cuts = { .2, .4, .6, .8 } })
  wing:each(function(x, y)
    if y == 15 or y == 16 then c:put(x, y, YEL[3], wT)
    elseif y == 17 then c:put(x, y, "#2c7842", wT)
    elseif y == 20 or y == 23 then c:put(x, y, BLUE[2], wT) end
  end)
end
local bI, bT = O.shade(c, c:ellipse(17, 21, 6, 6.5), RED, { sphere = { 15, 18, 9 }, amb = .3, wrap = .5, rim = true, bounce = "#7a4a9a", bmax = 2, sep = RED[1] })
O.tex(c, bI, bT, RED, function(x, y, i) if y >= 19 and y % 3 == 1 and (x + y) % 3 ~= 0 and i >= 3 then return -1 end end) -- breast scallops
for _, fx in ipairs({ 14, 18 }) do O.flat(c, c:rect(fx, 27, fx + 2, 27), BEAK[2], "toe") O.dot(c, fx, 27, BEAK[3]) end

O.shade(c, c:ellipse(17, 10.5, 7.5, 6.5), RED, { sphere = { 14, 7, 10 }, amb = .3, wrap = .5, rim = true, sep = RED[1] })
O.flat(c, c:rect(16, 3, 17, 3), RED[5], "crest")
-- beak
local up = c:poly{ { 15, 11 }, { 20, 11 }, { 20, 13 }, { 18, 16 }, { 17, 14 }, { 15, 13 } }
O.shade(c, up, BEAK, { R = 1, amb = .45, wrap = .5, sep = BEAK[1], cuts = { .35, .7, .9 } })
O.dots(c, { { 18, 16 }, { 18, 15 } }, BEAK[1])
O.dots(c, { { 15, 14 }, { 16, 14 }, { 16, 15 } }, "#5a1e2a") O.dot(c, 15, 15, BEAK[2])
O.dots(c, { { 15, 11 }, { 16, 11 }, { 17, 11 } }, BEAK[4])
O.dot(c, 18, 2, "#b6f0e0") O.dot(c, 18, 3, "#5fc4c8") -- rain drop on the crest

c:eyeSmall(12, 8)
c:eyeSmall(21, 8)
O.dot(c, 11, 12, "#f5809f") O.dot(c, 23, 12, "#f5809f")

O.shift(c, 0, -2)
O.done(c, "gc-parrot-pennant-perch", function(c)
  for dy = -2, 2 do c:put(27 + ((math.abs(dy) == 2) and 0 or 1), 10 + dy, "#fbe07a") end
  for dy = -4, 4 do c:put(30 + ((math.abs(dy) >= 3) and (math.abs(dy) == 4 and 0 or 1) or 2), 10 + dy, "#f8ecd0") end
end)
