-- Eightlegs Clasp (pl-sbs-4), perch sprite 36x36. Opus richness pass (c12/opus3), hand-built at this size.
-- Silverback spider from the front clasping a twig: silver abdomen with a plum chevron, plum head with the face,
-- plum legs fanned in a clean star that never cross, two short front legs clasping the twig under the chin. Face: 2x3 pills, cheeks, smile,
-- a row of tiny extra eyes above.
-- quirk: the back right leg is up in the air, wiggling (two ticks).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-4-perch", 36)

local SILV = { "#353556", "#56597e", "#8487a8", "#b0b3cc", "#d6d8e6", "#f0eef4" }
local PLUM = { "#2e1c3a", "#4a2e5c", "#6a467e", "#8e66a2", "#b28ec2", "#d4b8e0" }
local BARK = { "#3a2428", "#51302b", "#864c33", "#b97a4a", "#d39a62", "#e8b982" }

c:groundShadow(18, 33, 12, 1)
local tw, tn = O.tube({ { 3, 29 }, { 12, 27 }, { 24, 28 }, { 32, 30 } }, function() return 1.6 end)
O.shadeN(c, tw, tn, BARK, { amb = .25, wrap = .4, rim = true })
-- legs fanned like a star, each a simple bent stroke that never crosses another (opus2 weak spot: busy at
-- 1x): three on the left, two on the right plus the raised wiggling one, and the two short front legs clasping the twig under the chin. Eight in all.
local function leg(hip, knee, foot, w, band)
  local m1, n1 = O.tube({ hip, { (hip[1] + knee[1]) / 2, knee[2] }, knee, knee }, function() return w end)
  local m2, n2 = O.tube({ knee, { knee[1] + (foot[1] - knee[1]) * .2, knee[2] + 1 }, { foot[1], foot[2] - 3 }, foot }, function() return w - .1 end)
  m1:add(m2) for k, v in pairs(n2) do if not n1[k] then n1[k] = v end end
  local I, T = O.shadeN(c, m1, n1, PLUM, { amb = .3, wrap = .4, rim = true })
  if band then O.dot(c, knee[1], knee[2], PLUM[6]) end
end
leg({ 12, 12 }, { 6, 4 }, { 2, 10 }, .7, true)
leg({ 12, 16 }, { 5, 12 }, { 1, 19 }, .7, true)
leg({ 13, 20 }, { 7, 19 }, { 4, 27 }, .7)
leg({ 24, 16 }, { 31, 12 }, { 34, 19 }, .7, true)
leg({ 23, 20 }, { 29, 19 }, { 32, 27 }, .7)
-- the raised wiggling back right leg
local m1, n1 = O.tube({ { 24, 12 }, { 27, 8 }, { 29, 6 }, { 30, 5 } }, function() return .9 end)
O.shadeN(c, m1, n1, PLUM, { amb = .3, wrap = .4, sep = PLUM[1], rim = true })
local m2, n2 = O.tube({ { 30, 5 }, { 31, 4 }, { 32, 3 }, { 33, 3 } }, function() return .7 end)
O.shadeN(c, m2, n2, PLUM, { amb = .3, wrap = .4, sep = PLUM[1] })
O.dot(c, 30, 5, PLUM[6])

local abd = c:ellipse(18, 13, 7.5, 6.5)
local aI, aT = O.shade(c, abd, SILV, { sphere = { 15, 9, 11 }, amb = .25, wrap = .45, rim = true, bounce = "#7a6aa8", bmax = 2 })
O.tex(c, aI, aT, SILV, function(x, y, i)
  local dx = math.abs(x - 18)
  if y < 17 and dx < 4 and (y + dx) % 4 < 1 then return -3 end
end)
local head = c:ellipse(18, 21, 6.5, 5)
O.shade(c, head, PLUM, { sphere = { 15, 18, 9 }, amb = .35, wrap = .5, rim = true, bounce = "#5a6aa0", bmax = 2 })
-- the two front legs: short, clasping the twig under the chin
for _, f in ipairs({ { 15, 25, 14, 28 }, { 21, 25, 22, 28 } }) do
  local m, n = O.tube({ { f[1], f[2] }, { f[1], f[2] + 1 }, { f[3], f[4] - 1 }, { f[3], f[4] } }, function() return .7 end)
  O.shadeN(c, m, n, PLUM, { amb = .3, wrap = .4, sep = PLUM[1] })
end
O.dot(c, 13, 23, P.petal.base) O.dot(c, 23, 23, P.petal.base)
O.dots(c, { { 17, 24 }, { 18, 25 }, { 19, 24 } }, P.ink)

O.done(c, "pl-sbs-4-perch", function(c)
  c:eyeSmall(15, 20)
  c:eyeSmall(20, 20)
  for _, x in ipairs({ 15, 17, 19, 21 }) do c:put(x, 18, P.ink) end
  c:put(34, 1, P.ink) c:put(35, 2, P.ink) c:put(35, 5, P.ink) c:put(31, 0, P.ink)
end)
