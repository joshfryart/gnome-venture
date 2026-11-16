-- Talon Clutch (pl-cnd-4), perch sprite 36x36. Opus richness pass (c09/opus3), hand-built at this size.
-- opus3: a scaly shank rises from a flatter pad to a dark feather cuff, so it reads as the condor's foot and not
-- a round creature on a rock; lit talon ridges, scute rims on the toes, lichen on the rock.
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
  O.dot(c, p[1][1] + (p[2][1] < p[1][1] and -1 or 1) * 0, p[1][2] + 1, HORN[5])
end
O.dots(c, { { 6, 29 }, { 7, 29 } }, "#8aa070")
local FEA = { "#1c1626", "#2e2438", "#463852", "#665676", "#8c7a9a" }
local shank = c:poly({ { 15, 12 }, { 16, 3 }, { 20, 3 }, { 21, 12 } })
local sI, sT = O.shade(c, shank, SCALE, { R = 2, amb = .28, wrap = .45, rim = true, sep = SCALE[1] })
O.tex(c, sI, sT, SCALE, function(x, y, i) if y % 2 == 0 then return -1 end end)
local cuff = O.unionCircles({ { 15.5, 2.5, 1.8 }, { 18, 2, 2.2 }, { 20.5, 2.5, 1.8 } })
cuff:add(c:poly({ { 14, 3 }, { 16, 6 }, { 17, 3 } })) cuff:add(c:poly({ { 19, 3 }, { 20, 6 }, { 22, 3 } }))
O.shade(c, cuff, FEA, { R = 1, amb = .3, wrap = .5, rim = true, cuts = { .3, .5, .7, .86 }, sep = FEA[1] })
O.dots(c, { { 17, 1 }, { 15, 2 } }, FEA[5])
local pad = c:ellipse(18, 15.5, 8, 4.5)
local pI, pT = O.shade(c, pad, SCALE, { sphere = { 16, 12, 11 }, amb = .5, wrap = .55, rim = true, bounce = "#6f8fc0", bmax = 2, sep = SCALE[1] })
O.tex(c, pI, pT, SCALE, function(x, y, i) if y < 13 and (x + y) % 3 == 0 then return -1 end end)
c:eyeSmall(14, 13) c:eyeSmall(20, 13)
O.dot(c, 12, 16, P.petal.base) O.dot(c, 23, 16, P.petal.base)
O.dots(c, { { 16, 17 }, { 17, 17 }, { 18, 17 }, { 19, 17 } }, P.ink)
O.done(c, "pl-cnd-4-perch")
