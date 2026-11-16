-- Samovar Puff (bb-samovar-puff), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- quirk: tea drips from the spout onto a saucer.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("samovar-puff-perch", 36)
local BRASS = { "#5a2e14", "#8c4a1f", "#b97a2a", "#d98322", "#f5b82e", "#ffe38a" }
local TEA = { "#3a1a0e", "#5a2e14", "#8c4a1f" }
local STEAM = { "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6" }
c:groundShadow(17, 33, 9, 2)
O.flat(c, c:rect(11, 28, 13, 30), BRASS[2], "foot")
O.flat(c, c:rect(21, 28, 23, 30), BRASS[2], "foot")
O.dots(c, { { 15, 1 }, { 19, 2 }, { 17, 0 } }, STEAM[2])
O.shade(c, c:rrect(14, 4, 20, 12, 1), BRASS, { R = 1, sep = BRASS[1] })
local body = c:ellipse(17, 21, 8, 7)
O.shade(c, body, BRASS, { sphere = { 14, 18, 8 }, amb = .2, wrap = .35, sep = BRASS[1] })
O.shade(c, c:ellipse(17, 14, 5, 1), BRASS, { R = 1, sep = BRASS[1] })
local sm, sn = O.tube({ { 24, 24 }, { 27, 24 }, { 28, 26 }, { 30, 27 } }, function(t) return 1.5 - 0.6 * t end)
O.shadeN(c, sm, sn, BRASS, { amb = .3, sep = BRASS[1] })
O.dots(c, { { 30, 29 }, { 30, 31 } }, TEA[3])
O.shade(c, c:ellipse(30, 33, 3, 1), BRASS, { R = 1, sep = BRASS[1] })
c:eyeSmall(13, 19)
c:eyeSmall(19, 19)
O.dots(c, { { 15, 23 }, { 16, 24 }, { 17, 24 }, { 18, 24 }, { 19, 23 } }, P.ink)
O.done(c, "samovar-puff-perch")
