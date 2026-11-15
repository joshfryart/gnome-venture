-- Lantern Lark (dw-lantern-lark), yard sprite 64x64. Haiku pass, c03.
-- Seedkeeper, common. Round sand-brown songbird on a branch, with a lit paper lantern hung from its beak.
-- quirk: a gold music note floats up from the lantern.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("lantern-lark-yard", 64)

local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f6d8b0" }
local CREAM = { "#c98462", "#e8b982", "#f6d8b0", "#ffe0bd", "#fff0dc", "#fff4d6" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }
local TWIG  = { "#2b1c26", "#51302b", "#864c33", "#b97a4a" }

-- perch branch
local branch = O.tube({ { 6, 52 }, { 24, 53 }, { 40, 52 }, { 58, 51 } }, function(t) return 1.6 end)
O.flat(c, branch, TWIG[3], "branch")

-- tail
O.shade(c, c:poly({ { 18, 44 }, { 9, 50 }, { 13, 53 }, { 23, 47 } }), WOOD, { R = 1, sep = WOOD[1] })

-- body and wing
local body = c:ellipse(30, 38, 13, 11)
O.shade(c, body, WOOD, { sphere = { 26, 33, 13 }, amb = .2, wrap = .35, sep = WOOD[1], rim = true })
-- cream chest
O.shade(c, c:ellipse(35, 38, 5, 6), CREAM, { R = 1, sep = CREAM[1] })
local wing = O.tube({ { 22, 34 }, { 20, 40 }, { 17, 44 }, { 14, 45 } }, function(t) return 3 - 1.4 * t end)
local wm, wn = O.tube({ { 22, 34 }, { 20, 40 }, { 17, 44 }, { 14, 45 } }, function(t) return 3 - 1.4 * t end)
O.shadeN(c, wm, wn, WOOD, { amb = .2, wrap = .3, sep = WOOD[1] })

-- crest
local crm, crn = O.tube({ { 34, 22 }, { 33, 19 }, { 32, 16 }, { 30, 13 } }, function(t) return 1.8 - 0.8 * t end)
O.shadeN(c, crm, crn, WOOD, { amb = .3, sep = WOOD[1] })

-- head
local head = c:ellipse(38, 26, 7, 7)
O.shade(c, head, WOOD, { sphere = { 35, 23, 7 }, amb = .2, wrap = .35, sep = WOOD[1] })
-- short gold beak
O.shade(c, c:poly({ { 44, 23 }, { 49, 26 }, { 44, 28 } }), GOLD, { R = 1, sep = GOLD[1] })

-- legs gripping the branch
for _, x in ipairs({ 28, 34 }) do
  local lm, ln = O.tube({ { x, 48 }, { x, 50 }, { x, 51 }, { x, 52 } }, function(t) return .8 end)
  O.shadeN(c, lm, ln, GOLD, { amb = .3, sep = GOLD[1] })
end

-- quirk: lantern hung from the beak on a thread
local thread = O.tube({ { 46, 28 }, { 46, 32 }, { 45, 36 }, { 45, 38 } }, function(t) return .5 end)
O.flat(c, thread, TWIG[1], "thread")
local lantern = c:rrect(41, 38, 49, 47, 2)
O.shade(c, lantern, GOLD, { R = 2, sep = GOLD[1] })
O.flat(c, c:rect(44, 41, 46, 44), GOLD[5], "core")
O.flat(c, c:rect(40, 42, 40, 43), GOLD[1], "cap")
-- music note floating above
O.flat(c, c:rect(54, 18, 55, 21), GOLD[3], "note")
O.dot(c, 55, 22, GOLD[3]) O.dot(c, 53, 21, GOLD[3]) O.dot(c, 52, 22, GOLD[3])
O.dot(c, 56, 18, GOLD[4]) O.dot(c, 57, 19, GOLD[2])

-- face
c:eyeLocked(35, 22)
c:cheek(32, 29)
O.dots(c, { { 43, 26 } }, P.ink)

O.done(c, "lantern-lark-yard")
