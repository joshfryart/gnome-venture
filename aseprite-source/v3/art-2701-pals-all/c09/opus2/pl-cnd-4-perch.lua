-- Talon Clutch (pl-cnd-4), perch sprite 36x36. Opus second pass (c09/opus2), hand-built at this size.
-- Plump scaly mauve-pink foot pad (the face) with four ringed toes over a violet crag rock with a sandy top.
-- quirk: pale horn talons hooked into the rock, cracks spreading under them.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-4-perch", 36)
local SCALE = { "#4a2e36", "#74505a", "#9c7680", "#c29ea4", "#e0c4c4", "#f4e2dc" }
local HORN = { "#5a4030", "#8a6a4a", "#c0a070", "#e6cc98", "#f8ecc8" }
local ROCK = { "#261e36", "#3a2e4c", "#544468", "#705c84", "#8e78a0", "#ae98b8" }
local SAND = { "#c9a479", "#e6c995" }
c:groundShadow(18, 31, 13, 1.2)
local rock = c:poly({ { 5, 23 }, { 10, 21 }, { 18, 22 }, { 26, 21 }, { 31, 23 }, { 31, 28 }, { 32, 31 }, { 4, 31 }, { 5, 27 } })
local rI, rT = O.shade(c, rock, ROCK, { R = 2, amb = .3, wrap = .45, rim = true, bounce = "#6f8fc0", bmax = 2 })
rock:each(function(x, y) if not rock:has(x, y - 1) then c.pix[y * c.w + x] = SAND[2] end end)
O.dots(c, { { 9, 29 }, { 10, 30 }, { 25, 28 }, { 25, 29 } }, "#d9a040")
local toes = { { { 13, 17 }, { 10, 19 }, { 8, 21 }, { 8, 24 } }, { { 16, 19 }, { 15, 21 }, { 14, 22 }, { 14, 25 } },
               { { 20, 19 }, { 21, 21 }, { 22, 22 }, { 22, 25 } }, { { 23, 17 }, { 26, 19 }, { 28, 21 }, { 28, 24 } } }
for _, p in ipairs(toes) do
  local m, n, T = O.tube(p, function(t) return 2.2 - .6 * t end)
  local I, Tk = O.shadeN(c, m, n, SCALE, { amb = .28, wrap = .45, rim = true, sep = SCALE[1] })
  O.tex(c, I, Tk, SCALE, function(x, y) local t = T[K(x, y)] if t and (t * 6) % 2 < .4 then return -1 end end)
end
local claws = { { { 8, 24 }, { 7, 26 }, { 8, 28 }, { 9, 28 } }, { { 14, 25 }, { 13, 27 }, { 14, 29 }, { 15, 29 } },
                { { 22, 25 }, { 23, 27 }, { 22, 29 }, { 21, 29 } }, { { 28, 24 }, { 29, 26 }, { 28, 28 }, { 27, 28 } } }
for _, p in ipairs(claws) do
  local m, n = O.tube(p, function(t) return 1.2 * (1 - t) + .4 end)
  O.shadeN(c, m, n, HORN, { amb = .5, wrap = .6, cuts = { .25, .45, .65, .85 }, sep = HORN[1] })
end
local pad = c:ellipse(18, 13, 7, 6)
local pI, pT = O.shade(c, pad, SCALE, { sphere = { 15, 10, 9 }, amb = .3, wrap = .45, rim = true, bounce = "#6f8fc0", bmax = 2, sep = SCALE[1] })
O.tex(c, pI, pT, SCALE, function(x, y, i) if y < 10 and (x + y) % 3 == 0 then return -1 end end)
c:eyeSmall(14, 11) c:eyeSmall(20, 11)
O.dot(c, 12, 15, P.petal.base) O.dot(c, 23, 15, P.petal.base)
O.dots(c, { { 16, 16 }, { 17, 16 }, { 18, 16 }, { 19, 16 } }, P.ink)
O.done(c, "pl-cnd-4-perch")
