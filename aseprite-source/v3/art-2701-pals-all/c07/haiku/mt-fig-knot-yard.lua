-- Fig Knot (mt-fig-knot), yard 64x64. Haiku first pass, c07. Thornblade, uncommon, Monsoontangle.
-- A round knot of wood rope coils with moss leaves on top and a dusk-purple fig tucked in.
-- quirk: a cream folded note is wedged in the knot, a secret it will not let go of.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-fig-knot-yard", 64)

c:groundShadow(32, 59, 15, 3)
-- leaves on top
c:part(c:poly{ { 24, 18 }, { 14, 12 }, { 16, 22 } }, "moss")
c:part(c:poly{ { 40, 18 }, { 50, 12 }, { 48, 22 } }, "moss")
-- folded note peeking out of the knot
c:fillMask(c:rect(45, 24, 52, 30), P.cream)
c:fillMask(c:line({ { 46, 27 }, { 51, 27 } }, 1), P.wood.deep)
-- coiled body
c:part(c:ellipse(32, 37, 15, 14), "wood", { band = 3 })
c:fillMask(c:line({ { 19, 30 }, { 32, 25 }, { 45, 30 } }, 1), P.wood.deep)
c:fillMask(c:line({ { 18, 41 }, { 32, 45 }, { 46, 41 } }, 1), P.wood.deep)
-- fig tucked in the knot
c:part(c:ellipse(21, 48, 4, 4), "dusk", { band = 1 })
-- face
c:eyeLocked(24, 33)
c:eyeLocked(36, 33)
c:cheek(21, 40) c:cheek(40, 40)
c:px(30, 41, P.ink) c:px(31, 42, P.ink) c:px(32, 42, P.ink) c:px(33, 41, P.ink)

M.done(c, "mt-fig-knot-yard")
