-- Silkthread Tuft (pl-sbs-1), perch sprite 36x36. Opus second pass (c12/opus2), hand-built at this size.
-- Wide fluffy tuft of silver-lilac silk with a few spun strand grooves and a loose thread loop on top.
-- Face: 2x3 pills under worried brows (raised in the middle), cheeks, wobbly mouth.
-- quirk: a little green leaf stuck to its flank.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-1-perch", 36)

local SILK = { "#4a4466", "#6e6890", "#9a94b8", "#c2bed8", "#e2e0ee", "#f4f2fa" }
local LEAF = { "#24544a", "#2f6e4e", "#3f9150", "#7cc35a", "#c4e07a", "#e2f0a8" }

c:groundShadow(17, 31, 11, 1)
local m, n = O.tube({ { 12, 13 }, { 10, 2 }, { 22, 2 }, { 19, 12 } }, function() return .9 end)
O.shadeN(c, m, n, SILK, { amb = .35, wrap = .45 })
local fluff = O.unionCircles({ { 17, 23, 11, 6.5 }, { 11, 18, 5 }, { 23, 18, 5 }, { 17, 15, 5 }, { 7, 25, 3.5 }, { 27, 25, 3.5 } })
local fI, fT = O.shade(c, fluff, SILK, { sphere = { 14, 15, 15 }, amb = .3, wrap = .45, rim = true, bounce = "#7a8ab8", bmax = 2 })
O.tex(c, fI, fT, SILK, function(x, y, i)
  if y >= 17 and y <= 26 and x >= 10 and x <= 24 then return 0 end
  local dx, dy = x - 17, y - 20
  local w = (math.sqrt(dx * dx + dy * dy) * .7 + math.atan(dy, dx) * 2) % 3
  if w < .7 then return -1 end
end)
local leaf, ln = O.tube({ { 26, 21 }, { 29, 19 }, { 31, 20 }, { 33, 22 } }, function(t) return 1.8 * math.sin(math.pi * t) + .3 end)
O.shadeN(c, leaf, ln, LEAF, { amb = .3, wrap = .4, sep = LEAF[1] })
O.mark(c, { { 28, 20 }, { 30, 21 } }, LEAF[2])

O.dot(c, 10, 24, P.petal.base) O.dot(c, 24, 24, P.petal.base)
O.dots(c, { { 15, 25 }, { 16, 24 }, { 17, 25 }, { 18, 24 }, { 19, 25 } }, P.ink)

O.done(c, "pl-sbs-1-perch", function(c)
  c:eyeSmall(13, 20)
  c:eyeSmall(20, 20)
  c:put(13, 18, P.ink) c:put(14, 17, P.ink)
  c:put(20, 17, P.ink) c:put(21, 18, P.ink)
end)
