-- Sherbet Sip (dw-sherbet-sip), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- quirk: a thin mint-green stream falls from the high spout into a little cup.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sherbet-sip-perch", 36)
local PEACH = { "#7a4036", "#c98462", "#f0b98d", "#ffc9a0", "#ffe0bd", "#fff0dc" }
local MINT = { "#24544a", "#3f9150", "#7cc35a", "#a8d870", "#c4e07a" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
c:groundShadow(16, 33, 9, 2)
O.flat(c, c:rect(10, 29, 12, 31), PEACH[2], "foot")
O.flat(c, c:rect(19, 29, 21, 31), PEACH[2], "foot")
local body = c:ellipse(15, 23, 8, 7)
O.shade(c, body, PEACH, { sphere = { 12, 20, 8 }, amb = .2, wrap = .35, sep = PEACH[1], rim = true })
O.shade(c, c:ellipse(15, 16, 5, 1), PEACH, { R = 1, sep = PEACH[1] })
O.shade(c, c:ellipse(12, 14, 1, 1), MINT, { R = 1, sep = MINT[1] })
O.shade(c, c:ellipse(16, 13, 1, 1), MINT, { R = 1, sep = MINT[1] })
local sm, sn = O.tube({ { 21, 21 }, { 25, 18 }, { 28, 13 }, { 31, 8 } }, function(t) return 2 - 1 * t end)
O.shadeN(c, sm, sn, PEACH, { amb = .3, sep = PEACH[1] })
O.dots(c, { { 31, 10 }, { 31, 12 }, { 31, 14 }, { 31, 16 }, { 31, 18 } }, MINT[3])
O.shade(c, c:ellipse(31, 21, 2, 1), GOLD, { R = 1, sep = GOLD[1] })
c:eyeSmall(11, 21)
c:eyeSmall(17, 21)
O.dots(c, { { 13, 25 }, { 14, 26 }, { 15, 26 }, { 16, 26 } }, P.ink)
O.done(c, "sherbet-sip-perch")
