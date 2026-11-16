-- Owlet Peep (pl-owl-4), yard sprite 64x64. Thornblade, uncommon. A sleepy owlet in the den who peeps when bored.
-- quirk: a little cream peep mark rises from its beak, and its lids are half down.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-4-yard", 64)

local TAN = { "#4a3530", "#6e5040", "#9a7656", "#c4a078", "#e0c8a0", "#f2e4c8" }
local CRM = { "#8a6a4a", "#b08c66", "#d4b08a", "#e6cca8", "#f2e2c8", "#f8f0e0" }
local OCH = "#f5b82e"

local body = c:ellipse(32, 38, 19, 20)
O.shade(c, body, TAN, { sphere = { 28, 34, 18 }, amb = .2, wrap = .3, sep = TAN[1] })
local tufts = c:poly{ { 16, 22 }, { 14, 10 }, { 24, 20 } }
tufts:add(c:poly{ { 48, 22 }, { 50, 10 }, { 40, 20 } })
O.shade(c, tufts, TAN, { R = 1, amb = .25, sep = TAN[1] })

local face = c:ellipse(32, 30, 13, 11)
O.shade(c, face, CRM, { R = 3, amb = .3, sep = CRM[1] })
local belly = c:ellipse(32, 47, 11, 9)
O.shade(c, belly, CRM, { R = 3, amb = .3, sep = CRM[1] })

c:eyeLocked(24, 28)
c:eyeLocked(36, 28)
-- sleepy lid across the top of each eye
O.dots(c, { { 24, 28 }, { 25, 28 }, { 26, 28 }, { 27, 28 }, { 28, 28 } }, TAN[1])
O.dots(c, { { 36, 28 }, { 37, 28 }, { 38, 28 }, { 39, 28 }, { 40, 28 } }, TAN[1])
O.dots(c, { { 31, 33 }, { 32, 34 }, { 33, 33 } }, OCH)

-- quirk: peep marks off the beak
O.dots(c, { { 44, 25 }, { 46, 23 }, { 48, 21 } }, P.cream)

O.done(c, "pl-owl-4-yard")
