-- Cob Scout (mh-cob-scout), perch sprite 36x36. Opus richness pass (c00/opus3), hand-built at this size.
-- Richness pass: back husk leaves flop outward with hanging tips and a pale midrib, cool bounce on the cob,
-- pale fresh notches on the stick with a bold slash, the missing kernel (dark socket) top right.
-- Corn cob with a bold 3 px kernel grid (cleared round the face), silk tuft, husk leaves peeled down, 2x3 pill eyes.
-- quirk: the notched tally stick in its husk hand.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-cob-scout-perch", 36)

local CORN = { "#7a3a1f", "#b0601f", "#d98a22", "#f5b82e", "#ffd75a", "#fff0a0" }
local HUSK = { "#1f4438", "#2e6a40", "#3f9150", "#6fb055", "#a8d070", "#d8eca0" }
local SILK = { "#864c33", "#c98a55", "#e8c07a", "#f8e2a6" }
local WOOD = { "#3e2526", "#5e3428", "#864c33", "#b97a4a", "#d89c62", "#e8b982" }

c:groundShadow(18, 31, 12, 1.5)
for _, d in ipairs({ -1, 1 }) do
  local m, n, T0, S = O.tube({ { 18 + d * 2, 30 }, { 18 + d * 8, 27 }, { 18 + d * 12, 13 }, { 18 + d * 14, 22 } }, function(t) return 3.2 * (1 - t) ^ .7 + .4 end)
  local I, T = O.shadeN(c, m, n, HUSK, { amb = .25, wrap = .4, rim = true, sep = HUSK[1] })
  O.tex(c, I, T, HUSK, function(x, y, i) local v, t = S[K(x, y)], T0[K(x, y)]
    if v and math.abs(v) < .15 and t < .8 then return 1 end if t and t > .8 then return -1 end end)
end
local cob = c:ellipse(18, 16, 7, 11):add(c:ellipse(18, 20, 7.5, 7))
local cI, cT = O.shade(c, cob, CORN, { sphere = { 15, 12, 14 }, amb = .3, wrap = .45, rim = true, bounce = "#9a5a6a", bmax = 2 })
local function clear(x, y) return x >= 13 and x <= 23 and y >= 12 and y <= 21 end
O.tex(c, cI, cT, CORN, function(x, y, i)
  if clear(x, y) then return 0 end
  local col = (x - 12) % 3
  local r = (y + ((x - 12) // 3) % 2 * 2) % 4
  if col == 2 or r == 3 then return -2 end
  if col == 0 and r == 0 then return 1 end
end)
O.mark(c, { { 22, 8 }, { 23, 8 }, { 22, 9 } }, CORN[1])
for _, p in ipairs({ { { 17, 7 }, { 16, 4 }, { 13, 3 }, { 11, 4 } }, { { 19, 7 }, { 20, 4 }, { 22, 3 }, { 23, 4 } } }) do
  local m, n = O.tube(p, function(t) return .8 end)
  O.shadeN(c, m, n, SILK, { amb = .4, wrap = .5, cuts = { .3, .55, .8 } })
end
for _, d in ipairs({ -1, 1 }) do
  local m, n = O.tube({ { 18 + d, 30 }, { 18 + d * 5, 29 }, { 18 + d * 7, 27 }, { 18 + d * 5, 22 } }, function(t) return 3 * (1 - t) ^ .7 + .3 end)
  O.shadeN(c, m, n, HUSK, { amb = .25, wrap = .4, sep = HUSK[1] })
end
-- tally stick + hand
O.shade(c, c:rect(29, 7, 30, 27), WOOD, { R = 1, amb = .45, wrap = .5, sep = WOOD[1] })
for _, y in ipairs({ 8, 10, 12, 14 }) do O.dots(c, { { 29, y }, { 30, y } }, WOOD[1]) O.dots(c, { { 29, y - 1 }, { 30, y - 1 } }, WOOD[6]) end
O.dots(c, { { 30, 8 }, { 30, 9 }, { 30, 10 }, { 29, 12 }, { 29, 13 }, { 29, 14 } }, WOOD[3])
O.shade(c, c:rect(24, 18, 28, 19), HUSK, { R = 1, amb = .3, sep = HUSK[1] })
O.flat(c, c:rect(28, 17, 31, 19), HUSK[4], "grip") O.dots(c, { { 28, 17 }, { 29, 17 } }, HUSK[5])

c:eyeSmall(14, 13)
c:eyeSmall(20, 13)
O.dot(c, 13, 17, P.petal.base) O.dot(c, 23, 17, P.petal.base)
O.dots(c, { { 16, 18 }, { 17, 19 }, { 18, 19 }, { 19, 18 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "mh-cob-scout-perch")
