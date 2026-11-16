-- Sherbet Sip (dw-sherbet-sip), yard sprite 64x64. Haiku pass, c03.
-- Brewroot, common. Squat peach teapot with a mint sprig on its lid and a long spout held high.
-- quirk: a thin mint-green stream falls from the high spout into a little cup.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sherbet-sip-yard", 64)

local PEACH = { "#7a4036", "#c98462", "#f0b98d", "#ffc9a0", "#ffe0bd", "#fff0dc" }
local MINT  = { "#24544a", "#3f9150", "#7cc35a", "#a8d870", "#c4e07a" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(30, 58, 15, 3)

-- squat feet
O.flat(c, c:rect(18, 53, 23, 56), PEACH[2], "foot")
O.flat(c, c:rect(32, 53, 37, 56), PEACH[2], "foot")

-- round body
local body = c:ellipse(28, 40, 14, 13)
O.shade(c, body, PEACH, { sphere = { 24, 34, 14 }, amb = .2, wrap = .35, sep = PEACH[1], rim = true })

-- lid with a knob
O.shade(c, c:ellipse(28, 28, 8, 2), PEACH, { R = 1, sep = PEACH[1] })
O.shade(c, c:ellipse(28, 26, 2, 2), PEACH, { R = 1, sep = PEACH[1] })

-- mint sprig on the lid
O.shade(c, c:ellipse(25, 24, 2, 1), MINT, { R = 1, sep = MINT[1] })
O.shade(c, c:ellipse(31, 23, 2, 1), MINT, { R = 1, sep = MINT[1] })
O.dot(c, 28, 23, MINT[5])

-- left handle loop
local hm, hn = O.tube({ { 15, 33 }, { 8, 36 }, { 8, 45 }, { 15, 46 } }, function(t) return 1.2 end)
O.shadeN(c, hm, hn, PEACH, { amb = .3, sep = PEACH[1] })

-- tall curved spout, rising from the right shoulder
local sm, sn = O.tube({ { 40, 36 }, { 47, 30 }, { 52, 22 }, { 56, 14 } }, function(t) return 2.6 - 1.4 * t end)
O.shadeN(c, sm, sn, PEACH, { amb = .3, sep = PEACH[1] })

-- quirk: thin mint stream from the spout tip down into the cup
local stream = O.tube({ { 56, 16 }, { 57, 26 }, { 57, 38 }, { 56, 46 } }, function(t) return .6 end)
O.flat(c, stream, MINT[3], "stream")
O.dot(c, 56, 16, MINT[5])

-- small cup at the bottom of the stream
O.shade(c, c:ellipse(56, 52, 4, 2), GOLD, { R = 1, sep = GOLD[1] })
O.flat(c, c:rect(53, 50, 59, 50), MINT[4], "tea")

-- face: locked eyes, cheeks, smile
c:eyeLocked(21, 37)
c:eyeLocked(32, 37)
c:cheek(17, 43)
c:cheek(35, 43)
O.dots(c, { { 23, 44 }, { 24, 45 }, { 25, 45 }, { 26, 45 }, { 27, 45 } }, P.ink)

O.done(c, "sherbet-sip-yard")
