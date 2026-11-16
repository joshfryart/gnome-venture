-- Kernel Knock (mh-kernel-knock), perch sprite 36x36. Opus richness pass (c00/opus3), hand-built at this size.
-- Richness pass: a kernel wedge (opus2 was too round) with a softer split, crinkles in the puff, a butter drip.
-- Glossy gold kernel with a pale tip cap, its split top spilling a cream popcorn puff (three blooms), 2x3 pill
-- eyes and a small open mouth.
-- quirk: raised nub fist with two knock ticks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-kernel-knock-perch", 36)

local KER  = { "#7a3018", "#b0521c", "#dd7a1e", "#f5a82a", "#ffcf4a", "#fff0a0" }
local POP  = { "#8a6040", "#b88c5c", "#dcb98a", "#f0d9ae", "#fbeccb", "#fff6e0" }
local TIP  = { "#8f6a4a", "#c9a37a", "#ead2a8", "#f8ead0" }

c:groundShadow(17, 32, 9, 1)
for _, q in ipairs({ { 13, 7, 3.5 }, { 21, 7, 3.5 }, { 17, 5, 3.5 }, { 17, 10, 4 } }) do
  O.shade(c, c:ellipse(q[1], q[2], q[3], q[3] - .5), POP, { sphere = { q[1] - 1, q[2] - 1, q[3] + 1 }, amb = .35, wrap = .5, sep = POP[3], rim = true })
  O.mark(c, { { math.floor(q[1] + 1), math.floor(q[2] + 1) } }, POP[3])
end
local body = c:ellipse(17, 18, 8, 6)
body:add(c:poly{ { 9, 19 }, { 25, 19 }, { 19, 29 }, { 15, 29 } })
body:cut(c:poly{ { 7, 14 }, { 10, 15 }, { 13, 13 }, { 16, 15 }, { 19, 13 }, { 22, 15 }, { 25, 14 }, { 27, 14 }, { 27, 5 }, { 7, 5 } })
O.shade(c, body, KER, { sphere = { 14, 16, 11 }, amb = .25, wrap = .4, rim = true, bounce = "#8a4a6a", bmax = 2, sep = POP[2] })
O.mark(c, { { 22, 15 }, { 22, 16 }, { 22, 17 } }, "#ffe36a") O.mark(c, { { 22, 18 } }, "#e8b434")
O.shade(c, c:rect(15, 27, 18, 29), TIP, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = KER[2] })
-- raised knocking fist
local aR, nR = O.tube({ { 24, 20 }, { 27, 19 }, { 28, 17 }, { 28, 15 } }, function(t) return 1.3 end)
O.shadeN(c, aR, nR, KER, { amb = .3, wrap = .4, sep = KER[1] })
O.shade(c, c:ellipse(28.5, 13.5, 1.5, 1.5), KER, { R = 1, amb = .4, sep = KER[1] })

c:eyeSmall(13, 16)
c:eyeSmall(19, 16)
O.dot(c, 11, 20, P.petal.base) O.dot(c, 23, 20, P.petal.base)
O.flat(c, c:rect(16, 21, 17, 22), P.ink, "mouth")

O.shift(c, 0, 0)
O.done(c, "mh-kernel-knock-perch", function(c)
  for _, p in ipairs({ { 33, 10 }, { 34, 9 }, { 33, 13 }, { 34, 13 }, { 33, 16 }, { 34, 17 } }) do c:put(p[1], p[2], P.ink) end
end)
