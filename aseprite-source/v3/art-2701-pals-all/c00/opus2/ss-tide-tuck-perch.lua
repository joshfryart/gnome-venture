-- Tide Tuck (ss-tide-tuck), perch sprite 36x36. Opus second pass (c00/opus2), hand-built at this size.
-- Sand-gold dome tucked into a sand mound up to its chin, 2x3 pill eyes over the sand.
-- quirk: a small breaking wave curling over it from behind (hook-shaped tube of water, lit inner face, cream crest
-- and spray tip), replacing the first pass's blue slab.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-tide-tuck-perch", 36)

local SEA  = { "#1e3560", "#2a4a7a", "#2f6f9e", "#3f9cb8", "#6cc8c8", "#a8e8dc" }
local FOAM = { "#9cc8cc", "#d6ece4", "#fff4d6" }
local SAND = { "#8a6040", "#b88a58", "#d8ac72", "#ecca8e", "#f8e2ae" }
local SHEL = { "#7a3a2a", "#b0602e", "#d88c3a", "#f2b450", "#ffd678", "#fff0ae" }

c:groundShadow(18, 33, 16, 1)
local wp = { { 27, 30 }, { 31, 12 }, { 22, 2 }, { 13, 10 } }
local wave, wn, WT, WS = O.tube(wp, function(t) return 5.5 * (1 - t) ^ .6 + 1.1 end)
wave:cut(c:rect(0, 30, 35, 35))
local wI, wTk = O.shadeN(c, wave, wn, SEA, { amb = .22, wrap = .4 })
O.tex(c, wI, wTk, SEA, function(x, y, i)
  local s = WS[K(x, y)]
  if s and s < -.3 then return 1 end
  if s and s > .6 then return -1 end
end)
wave:each(function(x, y)
  local t, s = WT[K(x, y)], WS[K(x, y)]
  if t and s and t > .3 and t < .97 and s > .55 then local q = y * c.w + x if c.own[q] == wTk then c.pix[q] = FOAM[3] end end
end)
O.flat(c, c:ellipse(12, 11, 1.5, 1.5), FOAM[3], "spray")

local dome = c:ellipse(14, 24, 7.5, 7)
O.shade(c, dome, SHEL, { sphere = { 11, 20, 9 }, amb = .25, wrap = .4, rim = true, sep = SEA[1] })
O.mark(c, { { 9, 19 }, { 8, 21 }, { 19, 19 }, { 20, 21 } }, SHEL[3])
local sand = c:ellipse(18, 33, 15, 4.5)
sand:add(c:ellipse(14, 29, 10, 2.5))
sand:cut(c:rect(0, 33, 35, 35))
O.shade(c, sand, SAND, { R = 2, amb = .3, wrap = .45, cuts = { .25, .45, .65, .85 }, sep = SAND[1] })
for x = 25, 31 do if x % 2 == 0 then local q = 29 * c.w + x if c.own[q] then c.pix[q] = FOAM[3] end end end

c:eyeSmall(10, 21)
c:eyeSmall(16, 21)
O.dot(c, 8, 25, P.petal.base) O.dot(c, 19, 25, P.petal.base)
O.dots(c, { { 12, 25 }, { 13, 26 }, { 14, 26 }, { 15, 25 } }, P.ink)

O.shift(c, -1, -1)
O.done(c, "ss-tide-tuck-perch", function(c)
  for _, p in ipairs({ { 10, 9 }, { 9, 13 } }) do c:put(p[1], p[2], FOAM[2]) end
end)
