-- Reedleg Cling (pl-jdf-2), perch sprite 36x36. Opus third pass (c14/opus3), hand-built at this size.
-- opus3: reed nodes, a pale stripe down the abdomen, side spines, cool bounce, a pond ripple at the reed feet.
-- Jade dragonfly nymph between two golden reeds: broad head with bulging eyes (2x3 pills), wing-padded
-- thorax, banded abdomen with tail spikes, three legs a side clamped on the reeds; cattail on the right reed.
-- quirk: claws dug in, a bead of effort sweat.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-jdf-2-perch", 36)

local NYM  = { "#143632", "#1e5446", "#2c7a5e", "#4aa078", "#80c692", "#bce6b8" }
local REED = { "#4a3426", "#6e5030", "#987440", "#c09c58", "#dcc07a", "#f0dca4" }
local CAT  = { "#3a2224", "#5a3426", "#7e4c30", "#a46a40", "#c88c58" }
local CLAW = "#3a2a24"

c:groundShadow(18, 32, 13, 1.5)
for _, R in ipairs({ { { 7, 32 }, { 8, 22 }, { 7, 12 }, { 4, 4 } }, { { 29, 32 }, { 28, 22 }, { 29, 14 }, { 31, 8 } } }) do
  local m, n, T = O.tube(R, function(t) return 1.4 - .3 * t end)
  local I, Tk = O.shadeN(c, m, n, REED, { amb = .35, wrap = .45, rim = true, bounce = "#7a6a90", bmax = 2, sep = REED[1] })
  O.tex(c, I, Tk, REED, function(x, y, i) local t = T[K(x, y)] if t and (t * 4) % 1 < .07 then return -2 end end)
end
O.shade(c, c:rrect(29, 5, 32, 12, 1), CAT, { R = 1, amb = .4, wrap = .45, sep = CAT[1], cuts = { .25, .45, .65, .85 } })
for _, L in ipairs({ { 14, 17, 8, 16 }, { 14, 20, 8, 21 }, { 15, 23, 9, 25 }, { 22, 17, 28, 16 }, { 22, 20, 28, 21 }, { 21, 23, 28, 25 } }) do
  local kx, ky = (L[1] + L[3]) / 2, math.min(L[2], L[4]) - 3
  local m, n = O.tube({ { L[1], L[2] }, { kx, ky }, { kx, ky }, { L[3], L[4] } }, function() return .8 end)
  O.shadeN(c, m, n, NYM, { amb = .4, wrap = .45, sep = NYM[1] })
  O.dot(c, L[3], L[4] + 1, CLAW)
end
local abd = c:ellipse(18, 26, 3.5, 5) abd:add(c:poly{ { 16, 29 }, { 20, 29 }, { 18, 32 } })
local aI, aT = O.shade(c, abd, NYM, { sphere = { 17, 23, 7 }, amb = .3, wrap = .45, rim = true, bounce = "#5a6a9a", bmax = 2, sep = NYM[1] })
O.tex(c, aI, aT, NYM, function(x, y, i) if y > 22 and (y - 22) % 2 == 0 then return -2 end end)
O.dots(c, { { 14, 25 }, { 22, 27 } }, NYM[3])
O.shade(c, c:ellipse(18, 20, 4.5, 3.5), NYM, { sphere = { 16, 18, 6 }, amb = .32, wrap = .45, rim = true, sep = NYM[1] })
O.shade(c, c:ellipse(18, 14, 6.5, 4), NYM, { sphere = { 15, 11, 9 }, amb = .45, wrap = .5, rim = true, sep = NYM[1] })
for _, e in ipairs({ { 14.5, 11 }, { 21.5, 11 } }) do -- bulging eye domes, pale so the pills read
  O.shade(c, c:ellipse(e[1], e[2], 2.5, 2.5), NYM, { sphere = { e[1] - 1.5, e[2] - 1.5, 4 }, amb = .6, wrap = .6, sep = NYM[1] })
end
c:eyeSmall(14, 10)
c:eyeSmall(21, 10)
O.dot(c, 13, 15, P.petal.base) O.dot(c, 23, 15, P.petal.base)
O.dots(c, { { 16, 15 }, { 17, 15 }, { 18, 15 }, { 19, 15 }, { 20, 15 } }, P.ink) O.dots(c, { { 17, 16 }, { 19, 16 } }, P.ink)

O.done(c, "pl-jdf-2-perch", function(c)
  O.dot(c, 25, 7, "#a8dcf0") O.dot(c, 25, 8, "#5aa0c8")
  O.dots(c, { { 4, 34 }, { 5, 35 }, { 9, 35 }, { 10, 34 }, { 26, 34 }, { 27, 35 }, { 31, 35 }, { 32, 34 } }, "#a8dcf0")
end)
