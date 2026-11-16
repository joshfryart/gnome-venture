-- Tide Tuck (ss-tide-tuck), perch sprite 36x36. Opus richness pass (c00/opus3), hand-built at this size.
-- Cockle-shell dome tucked into a sand mound to its chin, 2x3 pill eyes over the sand, two paws on the blanket.
-- The pal is now the big central mass and the wave a slimmer curl behind it on the right (opus2 had the wave
-- outweigh the pal). Bold ribs only on the top of the shell; wet dark sand where the wave lands.
-- quirk: the pink starfish in the sand (a 3 px plus) on the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-tide-tuck-perch", 36)

local SEA  = { "#1c3058", "#264a7c", "#2c6e9c", "#3a9ab6", "#66c4c4", "#a6e6d8" }
local FOAM = { "#9cc8cc", "#d6ece4", "#fff4d6" }
local SAND = { "#86583e", "#b48452", "#d6a86c", "#ebc88a", "#f8e2ac" }
local WET  = { "#6a4a3e", "#8e6650", "#ad8460" }
local SHEL = { "#743228", "#ac5a2c", "#d68838", "#f0b04c", "#ffd474", "#fff0ac" }
local STAR = { "#9a3a4a", "#e0606a", "#ff9a8a" }

c:groundShadow(18, 33, 16, 1)
local wp = { { 29, 30 }, { 34, 15 }, { 28, 4 }, { 20, 8 } }
local wave, wn, WT, WS = O.tube(wp, function(t) return 3.6 * (1 - t) ^ .7 + 1.1 end)
wave:cut(c:rect(0, 30, 35, 35))
local wI, wTk = O.shadeN(c, wave, wn, SEA, { amb = .22, wrap = .4 })
O.tex(c, wI, wTk, SEA, function(x, y, i)
  local s = WS[K(x, y)]
  if s and s < -.3 then return 1 end
  if s and s > .6 then return -1 end
end)
wave:each(function(x, y)
  local t, s = WT[K(x, y)], WS[K(x, y)]
  if t and s and t > .3 and t < .97 and s > .5 then local q = y * c.w + x if c.own[q] == wTk then c.pix[q] = FOAM[3] end end
end)
O.flat(c, c:ellipse(19, 8, 1.5, 1), FOAM[3], "spray")

local dome = c:ellipse(15.5, 22, 9.5, 8)
local dI, dT = O.shade(c, dome, SHEL, { sphere = { 12, 18, 11 }, amb = .25, wrap = .4, rim = true, sep = SEA[1] })
O.tex(c, dI, dT, SHEL, function(x, y, i)
  if y >= 19 then return 0 end
  local a = math.atan(y - 30, x - 15.5)
  if (a / math.pi * 9) % 1 < .25 then return -1 end
end)
local sand = c:ellipse(18, 33, 16, 4.5)
sand:add(c:ellipse(15, 29, 11, 2.5))
sand:cut(c:rect(0, 33, 35, 35))
local sI, sT = O.shade(c, sand, SAND, { R = 2, amb = .3, wrap = .45, cuts = { .25, .45, .65, .85 }, sep = SAND[1] })
sand:each(function(x, y) if x >= 27 then local q = y * c.w + x if c.own[q] == sT then
  c.pix[q] = WET[math.max(1, math.min(3, (sI[K(x, y)] or 3) - 1))] end end end)
for x = 26, 33 do if x % 2 == 0 then local q = 29 * c.w + x if c.own[q] then c.pix[q] = FOAM[3] end end end
O.dots(c, { { 9, 28 }, { 21, 28 } }, SHEL[4]) O.dots(c, { { 10, 28 }, { 22, 28 } }, SHEL[2])
-- starfish
O.dots(c, { { 4, 30 }, { 3, 31 }, { 5, 31 }, { 4, 32 } }, STAR[2]) O.dot(c, 4, 31, STAR[3])

c:eyeSmall(11, 21)
c:eyeSmall(18, 21)
O.dot(c, 9, 25, P.petal.base) O.dot(c, 21, 25, P.petal.base)
O.dots(c, { { 14, 25 }, { 15, 26 }, { 16, 26 }, { 17, 25 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "ss-tide-tuck-perch", function(c)
  for _, p in ipairs({ { 17, 6 }, { 16, 10 } }) do c:put(p[1], p[2], FOAM[2]) end
end)
