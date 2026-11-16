-- Silkthread Tuft (pl-sbs-1), perch sprite 36x36. Opus richness pass (c12/opus3), hand-built at this size.
-- Wide fluffy tuft of silver-lilac silk with a few spun strand grooves and a loose thread loop on top.
-- Face: 2x3 pills under worried brows (raised in the middle), cheeks, wobbly mouth.
-- quirk: a little green leaf stuck to its flank.
-- opus3: the closed thread loop (read as a bag handle) is now an open question-mark curl of thread (a worried
-- cowlick); plum-to-pearl silk, one sticky bead, a stray wisp.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-1-perch", 36)

local SILK = { "#463c66", "#6a6290", "#9890ba", "#c2bcda", "#e2def0", "#f6f2f8" }
local LEAF = { "#24544a", "#2f6e4e", "#3f9150", "#7cc35a", "#c4e07a", "#e2f0a8" }

c:groundShadow(17, 31, 11, 1)
local cm, cn = HP.mask(), {}
for _, seg in ipairs({ { { 16, 12 }, { 16, 9 }, { 14, 7 }, { 14, 5 } }, { { 14, 5 }, { 14, 2 }, { 19, 1 }, { 20, 4 } }, { { 20, 4 }, { 21, 6 }, { 19, 7 }, { 18, 6 } } }) do
  local m, n = O.tube(seg, function() return .8 end)
  cm:add(m) for k, v in pairs(n) do cn[k] = v end
end
O.shadeN(c, cm, cn, SILK, { amb = .35, wrap = .45 })
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
O.mark(c, { { 8, 22 } }, "#dceef8") O.mark(c, { { 9, 23 } }, "#7f9cc8") -- sticky bead
O.dots(c, { { 5, 21 }, { 4, 20 } }, SILK[4]) -- stray wisp

O.dot(c, 10, 24, P.petal.base) O.dot(c, 24, 24, P.petal.base)
O.dots(c, { { 15, 25 }, { 16, 24 }, { 17, 25 }, { 18, 24 }, { 19, 25 } }, P.ink)

O.done(c, "pl-sbs-1-perch", function(c)
  c:eyeSmall(13, 20)
  c:eyeSmall(20, 20)
  c:put(13, 18, P.ink) c:put(14, 17, P.ink)
  c:put(20, 17, P.ink) c:put(21, 18, P.ink)
end)
