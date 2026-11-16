-- Mate Mumble (rr-mate-mumble), perch sprite 36x36. Opus second pass, hand-built at this size:
-- bulb gourd with silver rim and yerba crown, straw as a 2 px tube, pill eyes, pursed humming mouth.
-- quirk: one music note drifting off the straw tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mate-mumble-perch", 36)

local GRD  = { "#3e1e1e", "#64322a", "#8c4e34", "#b46e42", "#d4935a", "#ecbd82" }
local SILV = { "#444663", "#6c6e88", "#9496ac", "#bcbdcc", "#dddde6", "#f1eff4" }
local YERB = { "#24442c", "#3a6233", "#58823c", "#7ea24a", "#a6c266", "#c9dc8e" }
local NOTE = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }

c:groundShadow(16, 32, 10, 1.5)
for _, fx in ipairs({ 12, 20 }) do O.shade(c, c:ellipse(fx, 31, 2.5, 1.2), GRD, { R = 1, amb = .25 }) end

-- straw
local st, sn = O.tube({ { 18, 13 }, { 20, 9 }, { 22, 6 }, { 24, 3 } }, function(t) return .8 end)
O.shadeN(c, st, sn, SILV, { amb = .35, wrap = .4 })
O.dots(c, { { 24, 2 }, { 25, 2 } }, SILV[5]) O.dot(c, 21, 7, "#f5b82e")

-- gourd
local gourd = c:ellipse(16, 23, 9, 8.5)
gourd:add(c:ellipse(16, 15, 6, 3))
gourd:cut(c:rect(0, 32, 35, 35))
local gb = {}
gourd:each(function(x, y) if y == 17 and x % 2 == 0 then gb[K(x, y)] = -2 end end)
O.shade(c, gourd, GRD, { sphere = { 13, 19, 12 }, bias = gb, amb = .24, wrap = .45 })
O.dots(c, { { 10, 20 }, { 11, 19 } }, GRD[6])

-- rim + yerba
local rim = c:ellipse(16, 13.5, 6.5, 1.5)
O.shade(c, rim, SILV, { R = 1, amb = .4, cuts = { .25, .45, .62, .78, .9 } })
local yb = c:ellipse(16, 12, 5, 2.5)
yb:cut(c:rect(0, 13, 35, 35))
O.shade(c, yb, YERB, { R = 2, amb = .25, wrap = .4 })
O.dots(c, { { 14, 10 }, { 17, 11 } }, YERB[6]) O.dot(c, 19, 12, YERB[2])

-- face
c:eyeSmall(12, 20)
c:eyeSmall(19, 20)
O.dot(c, 9, 24, "#f5809f") O.dot(c, 23, 24, "#f5809f")
O.dot(c, 15, 23, GRD[6]) O.dot(c, 16, 23, GRD[5]) O.dots(c, { { 15, 24 }, { 16, 24 } }, GRD[2])
O.dots(c, { { 15, 26 }, { 16, 26 } }, "#3e1620") O.dots(c, { { 15, 27 }, { 16, 27 } }, "#8e2f3a")

-- quirk: a note
O.flat(c, c:rect(27, 9, 28, 10), NOTE[3], "note") O.dot(c, 27, 9, NOTE[4])
O.flat(c, c:rect(29, 5, 29, 9), NOTE[2], "note") O.dots(c, { { 30, 6 }, { 31, 7 } }, NOTE[3])

O.done(c, "mate-mumble-perch")
