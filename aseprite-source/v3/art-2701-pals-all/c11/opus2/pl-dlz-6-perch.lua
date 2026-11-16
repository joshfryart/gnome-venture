-- Mossback Monitor (pl-dlz-6), perch sprite 36x36. Opus second pass (c11/opus2), hand-built at this size.
-- Slate-blue monitor lying on a jungle leaf with a gold midrib, neck up, head to the right, cream rosettes,
-- yellow-green moss cushion on the back with one red toadstool. 2x3 pill eyes.
-- quirk: the polish shine streaks along back and head, plus a sparkle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-dlz-6-perch", 36)

local MON  = { "#1c1c2c", "#2a2e42", "#3e4858", "#5a6a70", "#84968c", "#b8c6a8" }
local ROSE = "#ece0b0"
local LEAF = { "#14363a", "#1c5448", "#287658", "#40a06a", "#78c880", "#b4e8a0" }
local MOSS = { "#3a4418", "#5c6c22", "#86a030", "#b6cc48", "#e0ea7a" }
local MUSH = { "#7a2030", "#c43a3a", "#ee6a4a", "#fde0b0" }
local GOLD = "#e0a032"
local SHIN = "#eef0c8"

c:groundShadow(18, 33, 16, 1)
local leaf = c:ellipse(18, 29.5, 15, 2.5)
leaf:add(c:poly{ { 5, 29 }, { 3, 26 }, { 7, 28 } })
O.shade(c, leaf, LEAF, { R = 2, amb = .3, wrap = .4, rim = true })
for x = 4, 32 do O.mark(c, { { x, 29 } }, x % 2 == 0 and GOLD or LEAF[5]) end
local tail, tn = O.tube({ { 10, 25 }, { 5, 24 }, { 4, 29 }, { 9, 31 } }, function(t) return 2 * (1 - .75 * t) + .3 end)
O.shadeN(c, tail, tn, MON, { amb = .3, wrap = .4, rim = true, sep = MON[1] })
local body = c:ellipse(16, 23, 8.5, 4.5)
O.shade(c, body, MON, { sphere = { 13, 18, 12 }, amb = .32, wrap = .45, rim = true, sep = MON[1] })
O.mark(c, { { 11, 24 }, { 15, 25 }, { 19, 24 }, { 22, 23 } }, ROSE)
for _, L in ipairs({ { 10, 26 }, { 21, 26 } }) do
  O.flat(c, c:rect(L[1], L[2], L[1] + 1, 28), MON[3], "leg")
  O.dots(c, { { L[1] - 1, 28 }, { L[1] + 2, 28 } }, MON[5])
end
O.dot(c, 22, 28, GOLD)
local neck, nn = O.tube({ { 22, 21 }, { 25, 19 }, { 26, 16 }, { 26, 13 } }, function(t) return 2.8 - .6 * t end)
O.shadeN(c, neck, nn, MON, { amb = .3, wrap = .45, rim = true })
local head = c:ellipse(27, 11, 5.5, 4)
head:add(c:ellipse(30, 13, 3.5, 2.5))
O.shade(c, head, MON, { sphere = { 25, 8, 8 }, amb = .38, wrap = .45, rim = true, sep = MON[1] })
O.dots(c, { { 27, 15 }, { 28, 15 }, { 29, 15 }, { 30, 15 }, { 31, 14 } }, P.ink)
c:eyeSmall(24, 9)
c:eyeSmall(29, 9)
O.dot(c, 27, 13, P.petal.base)
local moss = c:ellipse(14, 18.5, 6, 2)
local mI, mT = O.shade(c, moss, MOSS, { sphere = { 12, 17, 7 }, amb = .35, wrap = .45, cuts = { .2, .42, .65, .85 }, sep = MON[2] })
O.tex(c, mI, mT, MOSS, function(x, y, i) if H(x, y, 11) > .7 then return 1 end end)
O.flat(c, c:rect(15, 15, 15, 16), MUSH[4], "stalk")
O.flat(c, c:rect(14, 14, 16, 14), MUSH[2], "cap") O.dot(c, 14, 14, MUSH[3]) O.dot(c, 15, 13, MUSH[2])
O.mark(c, { { 20, 20 }, { 21, 20 }, { 25, 8 }, { 26, 7 }, { 27, 7 }, { 24, 17 } }, SHIN)

O.shift(c, -1, 0)
O.done(c, "pl-dlz-6-perch", function(c) c:sparkle(30, 4) end)
