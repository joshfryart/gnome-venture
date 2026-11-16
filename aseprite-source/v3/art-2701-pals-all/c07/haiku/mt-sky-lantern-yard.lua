-- Sky Lantern (mt-sky-lantern), yard 64x64. Haiku first pass, c07. Rootwarden, uncommon, Monsoontangle.
-- A paper lantern with a glowing gold core, wood caps and a tri-point top, trailing sky ribbons.
-- quirk: two sky ribbons trail below it like a tail, and it has a little grin.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-sky-lantern-yard", 64)

-- ribbons behind the lantern
c:part(c:line({ { 29, 54 }, { 25, 62 } }, 2), "sky")
c:part(c:line({ { 35, 54 }, { 39, 62 } }, 2), "sky")
-- paper body
c:part(c:ellipse(32, 33, 15, 17), "ember", { band = 3 })
-- paper ribs
c:fillMask(c:line({ { 22, 22 }, { 21, 44 } }, 1), P.ember.deep)
c:fillMask(c:line({ { 42, 22 }, { 43, 44 } }, 1), P.ember.deep)
c:fillMask(c:line({ { 27, 17 }, { 26, 50 } }, 1), P.ember.deep)
c:fillMask(c:line({ { 37, 17 }, { 38, 50 } }, 1), P.ember.deep)
-- glowing core
c:part(c:ellipse(32, 35, 5, 6), "gold", { band = 2 })
-- wood caps and tri-point top
c:part(c:rect(23, 12, 41, 15), "wood")
c:part(c:rect(23, 50, 41, 53), "wood")
c:part(c:poly{ { 30, 12 }, { 34, 12 }, { 32, 7 } }, "wood")
-- face
c:eyeLocked(25, 29)
c:eyeLocked(35, 29)
c:px(30, 37, P.ink) c:px(31, 38, P.ink) c:px(32, 38, P.ink) c:px(33, 38, P.ink) c:px(34, 37, P.ink)
-- rain-hurry dashes on the right (quirk)
c:fillMask(c:line({ { 50, 22 }, { 54, 22 } }, 1), P.sky.base)
c:fillMask(c:line({ { 51, 28 }, { 55, 28 } }, 1), P.sky.base)

M.done(c, "mt-sky-lantern-yard")
