-- Lantern Lark (dw-lantern-lark), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- quirk: a gold music note floats up from the lantern.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("lantern-lark-perch", 36)
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f6d8b0" }
local CREAM = { "#c98462", "#e8b982", "#f6d8b0", "#ffe0bd", "#fff0dc", "#fff4d6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }
local TWIG = { "#2b1c26", "#51302b", "#864c33", "#b97a4a" }
local branch = O.tube({ { 3, 30 }, { 12, 31 }, { 24, 30 }, { 34, 29 } }, function(t) return 1.2 end)
O.flat(c, branch, TWIG[3], "branch")
O.shade(c, c:poly({ { 11, 22 }, { 5, 27 }, { 8, 29 }, { 13, 25 } }), WOOD, { R = 1, sep = WOOD[1] })
local body = c:ellipse(16, 22, 7, 6)
O.shade(c, body, WOOD, { sphere = { 13, 19, 7 }, amb = .2, wrap = .35, sep = WOOD[1], rim = true })
O.shade(c, c:ellipse(18, 23, 3, 3), CREAM, { R = 1, sep = CREAM[1] })
local wm, wn = O.tube({ { 14, 19 }, { 12, 23 }, { 9, 25 }, { 7, 26 } }, function(t) return 1.8 - 0.8 * t end)
O.shadeN(c, wm, wn, WOOD, { amb = .2, wrap = .3, sep = WOOD[1] })
local head = c:ellipse(22, 15, 4, 4)
O.shade(c, head, WOOD, { sphere = { 20, 13, 4 }, amb = .2, wrap = .35, sep = WOOD[1] })
local crm, crn = O.tube({ { 20, 11 }, { 19, 9 }, { 18, 7 }, { 17, 5 } }, function(t) return 1.2 - 0.5 * t end)
O.shadeN(c, crm, crn, WOOD, { amb = .3, sep = WOOD[1] })
O.shade(c, c:poly({ { 25, 13 }, { 28, 15 }, { 25, 16 } }), GOLD, { R = 1, sep = GOLD[1] })
c:eyeSmall(21, 14)
local thread = O.tube({ { 25, 16 }, { 25, 18 }, { 25, 20 }, { 25, 21 } }, function(t) return .4 end)
O.flat(c, thread, TWIG[1], "thread")
O.shade(c, c:rrect(23, 22, 27, 28, 1), GOLD, { R = 1, sep = GOLD[1] })
O.dot(c, 25, 24, GOLD[5]) O.dot(c, 26, 24, GOLD[5]) O.dot(c, 25, 25, GOLD[5])
O.dots(c, { { 31, 9 }, { 32, 8 }, { 32, 10 }, { 33, 11 }, { 30, 6 } }, GOLD[3])
O.done(c, "lantern-lark-perch")
