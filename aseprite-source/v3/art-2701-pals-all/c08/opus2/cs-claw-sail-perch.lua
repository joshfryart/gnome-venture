-- Claw Sail (cs-claw-sail), perch sprite 36x36. Opus second pass, hand-built at this size: red crab in a slim
-- wooden canoe on a strip of sea, eyes on stalks (2x3 pills), claws up, a sky-blue crab-claw sail with a concave
-- top and one seam, wooden spars.
-- quirk: the very large grin with a row of cream teeth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-claw-sail-perch", 36)

local RED  = { "#5a1830", "#94263a", "#c83a3a", "#e8603e", "#ff9268", "#ffc4a0" }
local WOOD = { "#3e2420", "#5e3428", "#864c33", "#b97a4a", "#d89a62", "#f0c48c" }
local SAIL = { "#3a5a9a", "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

c:groundShadow(18, 33, 12, 1.5)
-- sail
do
  local ax, ay = 25, 25
  local sail = HP.mask()
  for y = 2, ay do for x = 17, 33 do
    local t = (ay - y) / 22
    local lx, rx = ax - 4 * t - 1 * math.sin(t * math.pi), ax + 9 * t + 1.5 * math.sin(t * math.pi)
    local top = 3 + 5 * math.max(0, 1 - ((x - 27.5) / 7) ^ 2)
    if x >= lx and x <= rx and y >= top then sail:set(x, y) end
  end end
  local sI, sT = O.shade(c, sail, SAIL, { R = 3, amb = .25, wrap = .4, cuts = { .25, .45, .65, .85 } })
  O.tex(c, sI, sT, SAIL, function(x, y, i)
    local t = (ay - y) / 22
    local lx, rx = ax - 4 * t - 1 * math.sin(t * math.pi), ax + 9 * t + 1.5 * math.sin(t * math.pi)
    if rx - lx < 3 then return end
    if math.abs((x - lx) / (rx - lx) - .5) < .08 then return -2 end
  end)
  O.flat(c, (O.tube({ { ax, ay }, { 23, 16 }, { 22, 9 }, { 21, 3 } }, function() return .7 end)), WOOD[3], "spar")
  O.flat(c, (O.tube({ { ax, ay }, { 29, 16 }, { 31, 10 }, { 33, 5 } }, function() return .7 end)), WOOD[3], "spar")
end
-- crab
O.shade(c, c:ellipse(14, 22, 8, 5), RED, { sphere = { 12, 19, 9 }, amb = .28, wrap = .4, sep = RED[1], rim = true, bounce = "#5a6ab0", bmax = 2 })
O.flat(c, c:rect(10, 15, 10, 18), RED[3], "stalk") O.flat(c, c:rect(17, 15, 17, 18), RED[3], "stalk")
O.shade(c, c:ellipse(10.5, 14, 2, 2), RED, { R = 1, amb = .4, sep = RED[1] })
O.shade(c, c:ellipse(17.5, 14, 2, 2), RED, { R = 1, amb = .4, sep = RED[1] })
-- claws
for _, s in ipairs({ { 5, 17, 8, 22 }, { 24, 17, 21, 22 } }) do
  local m, n = O.tube({ { s[3], s[4] }, { (s[1] + s[3]) / 2, s[4] }, { s[1], s[4] - 2 }, { s[1], s[2] + 1 } }, function() return 1.1 end)
  O.shadeN(c, m, n, RED, { amb = .3, sep = RED[1] })
  O.shade(c, c:ellipse(s[1], s[2], 2, 2), RED, { R = 1, amb = .35, sep = RED[1] })
  O.shade(c, c:rect(s[1] - 1, s[2] - 4, s[1] - 1, s[2] - 2), RED, { R = 1, amb = .45 })
  O.shade(c, c:rect(s[1] + 1, s[2] - 3, s[1] + 1, s[2] - 2), RED, { R = 1, amb = .45 })
end
-- hull
local hull = c:poly{ { 2, 23 }, { 5, 25 }, { 30, 25 }, { 33, 22 }, { 31, 27 }, { 28, 30 }, { 7, 30 }, { 4, 27 } }
O.shade(c, hull, WOOD, { R = 2, amb = .28, wrap = .35, sep = WOOD[1], rim = true })
O.flat(c, c:rect(4, 25, 30, 25), WOOD[5], "gunwale")
for x = 8, 28, 5 do O.dots(c, { { x, 27 }, { x + 1, 26 }, { x + 2, 27 } }, "#fff4d6") end
-- sea
local sea = HP.mask()
for x = 3, 32 do local top = 29 + ((x // 3) % 2) for y = top, 31 do sea:set(x, y) end end
O.shade(c, sea, SEA, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
-- face
c:eyeSmall(10, 13)
c:eyeSmall(17, 13)
O.dots(c, { { 8, 20 }, { 20, 20 } }, "#f5809f")
O.dots(c, { { 9, 21 }, { 10, 21 }, { 11, 21 }, { 12, 21 }, { 13, 21 }, { 14, 21 }, { 15, 21 }, { 16, 21 }, { 17, 21 }, { 18, 21 }, { 19, 21 },
            { 9, 22 }, { 19, 22 }, { 10, 23 }, { 11, 23 }, { 12, 23 }, { 13, 23 }, { 14, 23 }, { 15, 23 }, { 16, 23 }, { 17, 23 }, { 18, 23 } }, P.ink)
O.dots(c, { { 10, 22 }, { 11, 22 }, { 12, 22 }, { 13, 22 }, { 14, 22 }, { 15, 22 }, { 16, 22 }, { 17, 22 }, { 18, 22 } }, "#fff4d6")
O.dots(c, { { 13, 22 }, { 17, 22 } }, "#f5809f")
O.shift(c, 0, -1)
O.done(c, "cs-claw-sail-perch")
