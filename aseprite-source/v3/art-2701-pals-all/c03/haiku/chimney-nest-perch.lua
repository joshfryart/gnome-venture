-- Chimney Nest (bb-chimney-nest), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- quirk: a red bow is tied on the nest rim.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("chimney-nest-perch", 36)
local BRICK = { "#51302b", "#6e2038", "#864c33", "#b52e3f", "#b97a4a", "#e8b982" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f6d8b0" }
local STORK = { "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6", "#f4eee6", "#fff4d6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local RED = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
O.shade(c, c:rrect(7, 29, 29, 34, 1), BRICK, { R = 1, sep = BRICK[1] })
O.shade(c, c:ellipse(18, 27, 9, 4), WOOD, { sphere = { 15, 25, 9 }, amb = .25, wrap = .35, sep = WOOD[1] })
O.dots(c, { { 12, 27 }, { 13, 27 }, { 22, 28 }, { 23, 28 } }, WOOD[5])
O.shade(c, c:ellipse(12, 26, 1, 1), STORK, { R = 1, sep = STORK[1] })
local nm, nn = O.tube({ { 17, 25 }, { 17, 21 }, { 18, 17 }, { 19, 14 } }, function(t) return 2 - 0.6 * t end)
O.shadeN(c, nm, nn, STORK, { amb = .2, wrap = .35, sep = STORK[1] })
O.shade(c, c:ellipse(20, 11, 3, 3), STORK, { sphere = { 19, 10, 3 }, amb = .2, sep = STORK[1] })
local bm, bn = O.tube({ { 22, 11 }, { 25, 11 }, { 28, 11 }, { 31, 11 } }, function(t) return .9 - 0.3 * t end)
O.shadeN(c, bm, bn, GOLD, { amb = .3, sep = GOLD[1] })
c:eyeSmall(19, 10)
O.shade(c, c:ellipse(25, 25, 1, 1), RED, { R = 1, sep = RED[1] })
O.dots(c, { { 26, 26 }, { 27, 27 } }, RED[2])
O.done(c, "chimney-nest-perch")
