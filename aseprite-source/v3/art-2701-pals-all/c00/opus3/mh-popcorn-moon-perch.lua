-- Popcorn Moon (mh-popcorn-moon), perch sprite 36x36. Opus richness pass (c00/opus3), hand-built at this size.
-- Richness pass: soft maria on the crescent, a tapered lower horn, crinkled popcorn with the unpopped kernel,
-- bolder pop ticks.
-- Butter-gold crescent with a wide belly for the 2x3 pill eyes (well clear of the inner cut), one crater, one sparkle.
-- quirk: cream popcorn bursting off the upper horn, one piece flying with a pop tick.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-popcorn-moon-perch", 36)

local MOON = { "#6e3a2a", "#a8622a", "#d99030", "#f5c048", "#ffe07a", "#fff3b8" }
local POP  = { "#8a6040", "#b88c5c", "#dcb98a", "#f0d9ae", "#fbeccb", "#fff6e0" }

local moon = c:ellipse(16, 19, 13, 13)
moon:cut(c:ellipse(25, 14, 10, 10.5))
moon:cut(c:poly{ { 21, 33 }, { 31, 33 }, { 31, 24 } })
local mI, mT = O.shade(c, moon, MOON, { sphere = { 11, 14, 17 }, amb = .3, wrap = .5, rim = true, bounce = "#9a5a7a", bmax = 2 })
O.tex(c, mI, mT, MOON, function(x, y, i)
  if x >= 6 and x <= 15 and y >= 16 and y <= 23 then return 0 end
  local v = math.sin(x * .5 + 1.3) + math.sin(y * .45 + .4) + math.sin((x + y) * .3)
  if v > 1.4 and i >= 3 then return -1 end
end)
O.mark(c, { { 11, 27 }, { 12, 27 } }, MOON[3]) O.mark(c, { { 11, 28 }, { 12, 28 } }, MOON[5])
O.mark(c, { { 5, 17 }, { 5, 18 }, { 6, 15 } }, MOON[6])
for _, q in ipairs({ { 16, 5, 2.2 }, { 19, 4, 2.2 }, { 18, 7, 2 } }) do
  O.shade(c, c:ellipse(q[1], q[2], q[3], q[3]), POP, { sphere = { q[1] - 1, q[2] - 1, q[3] + 1 }, amb = .35, wrap = .5, sep = POP[3] })
end
O.shade(c, c:ellipse(26, 4, 1.8, 1.8), POP, { sphere = { 25, 3, 3 }, amb = .4, wrap = .5 })
O.dots(c, { { 19, 5 }, { 20, 6 } }, POP[3])
O.dots(c, { { 14, 6 }, { 14, 7 } }, "#dd7a1e") O.dot(c, 14, 6, "#f5a82a")

c:eyeSmall(7, 17)
c:eyeSmall(12, 17)
O.dot(c, 5, 21, P.petal.base) O.dot(c, 15, 21, P.petal.base)
O.dots(c, { { 9, 22 }, { 10, 23 }, { 11, 22 } }, P.ink)

O.shift(c, 2, 0)
O.done(c, "mh-popcorn-moon-perch", function(c)
  c:sparkle(30, 22)
  for _, p in ipairs({ { 30, 2 }, { 31, 1 }, { 31, 5 }, { 32, 5 }, { 30, 8 }, { 31, 9 } }) do c:put(p[1], p[2], P.ink) end
end)
