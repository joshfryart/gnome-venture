-- Eightlegs Clasp (pl-sbs-4), perch sprite 36x36. Opus second pass (c12/opus2), hand-built at this size.
-- Silverback spider from the front clasping a twig: silver abdomen with a plum chevron, plum head with the face,
-- thick jointed plum legs fanned at different knee heights (pale knee bands). Face: 2x3 pills, cheeks, smile,
-- a row of tiny extra eyes above.
-- quirk: the back right leg is up in the air, wiggling (two ticks).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-4-perch", 36)

local SILV = { "#3a3a56", "#5c5e7e", "#8a8ca8", "#b4b6cc", "#d8dae6", "#eef0f6" }
local PLUM = { "#2e1c3a", "#4a2e5c", "#6a467e", "#8e66a2", "#b28ec2", "#d4b8e0" }
local BARK = { "#3a2428", "#51302b", "#864c33", "#b97a4a", "#d39a62", "#e8b982" }

c:groundShadow(18, 33, 12, 1)
local tw, tn = O.tube({ { 3, 29 }, { 12, 27 }, { 24, 28 }, { 32, 30 } }, function() return 1.6 end)
O.shadeN(c, tw, tn, BARK, { amb = .25, wrap = .4, rim = true })
local function leg(hip, knee, foot, w)
  local m1, n1 = O.tube({ hip, { (hip[1] + knee[1]) / 2, knee[2] }, knee, knee }, function() return w end)
  local m2, n2 = O.tube({ knee, { knee[1] + (foot[1] - knee[1]) * .3, knee[2] + 1 }, { foot[1], foot[2] - 2 }, foot }, function() return w - .2 end)
  O.shadeN(c, m2, n2, PLUM, { amb = .3, wrap = .4, sep = PLUM[1] })
  O.shadeN(c, m1, n1, PLUM, { amb = .3, wrap = .4, sep = PLUM[1], rim = true })
  O.dot(c, knee[1], knee[2], PLUM[6])
end
leg({ 13, 14 }, { 6, 6 }, { 4, 27 }, 1)
leg({ 13, 18 }, { 3, 16 }, { 8, 27 }, 1)
leg({ 14, 22 }, { 7, 22 }, { 12, 26 }, 1)
leg({ 23, 18 }, { 32, 16 }, { 28, 27 }, 1)
leg({ 22, 22 }, { 29, 22 }, { 24, 26 }, 1)
local m1, n1 = O.tube({ { 23, 14 }, { 25, 10 }, { 27, 8 }, { 28, 7 } }, function() return 1 end)
O.shadeN(c, m1, n1, PLUM, { amb = .3, wrap = .4, sep = PLUM[1], rim = true })
local m2, n2 = O.tube({ { 28, 7 }, { 30, 6 }, { 31, 5 }, { 31, 4 } }, function() return .8 end)
O.shadeN(c, m2, n2, PLUM, { amb = .3, wrap = .4, sep = PLUM[1] })
O.dot(c, 28, 7, PLUM[6])

local abd = c:ellipse(18, 13, 7.5, 6.5)
local aI, aT = O.shade(c, abd, SILV, { sphere = { 15, 9, 11 }, amb = .25, wrap = .45, rim = true, bounce = "#7a6aa8", bmax = 2 })
O.tex(c, aI, aT, SILV, function(x, y, i)
  local dx = math.abs(x - 18)
  if y < 17 and dx < 4 and (y + dx) % 4 < 1 then return -3 end
end)
local head = c:ellipse(18, 21, 6.5, 5)
O.shade(c, head, PLUM, { sphere = { 15, 18, 9 }, amb = .35, wrap = .5, rim = true })
O.dot(c, 13, 23, P.petal.base) O.dot(c, 23, 23, P.petal.base)
O.dots(c, { { 17, 24 }, { 18, 25 }, { 19, 24 } }, P.ink)

O.done(c, "pl-sbs-4-perch", function(c)
  c:eyeSmall(15, 20)
  c:eyeSmall(20, 20)
  for _, x in ipairs({ 15, 17, 19, 21 }) do c:put(x, 18, P.ink) end
  c:put(33, 3, P.ink) c:put(34, 2, P.ink) c:put(33, 6, P.ink) c:put(29, 2, P.ink)
end)
