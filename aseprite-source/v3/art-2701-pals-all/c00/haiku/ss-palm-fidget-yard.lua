-- Palm Fidget (ss-palm-fidget), yard 64x64. Haiku first pass, c00. Bloomcaller, common, Sunsprinkle.
-- A round coconut body with three moss-green palm fronds sprouting from the top, bent by the breeze.
-- quirk: one frond is curled into a fidget loop, and breeze ticks blow off to the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("ss-palm-fidget-yard", 64)

c:groundShadow(32, 58, 13, 3)
-- fronds, bent by the breeze
c:part(c:line({ { 31, 26 }, { 20, 16 }, { 8, 20 } }, 3), "moss")
c:part(c:line({ { 33, 26 }, { 44, 14 }, { 56, 16 } }, 3), "moss")
-- the fidget frond: a tight curl
c:part(c:line({ { 32, 24 }, { 33, 10 }, { 40, 6 }, { 44, 10 }, { 41, 13 } }, 2), "moss")
-- coconut body
c:part(c:ellipse(32, 40, 15, 14), "wood")
-- breeze ticks (quirk)
c:fillMask(c:line({ { 50, 36 }, { 58, 34 } }, 1), P.sky.base)
c:fillMask(c:line({ { 50, 42 }, { 56, 42 } }, 1), P.sky.base)
-- coconut eyes-marks and face
for _, p in ipairs({ { 25, 52 }, { 34, 53 } }) do c:px(p[1], p[2], P.wood.deep) end
c:eyeLocked(24, 37)
c:eyeLocked(36, 37)
c:cheek(20, 43) c:cheek(41, 43)
c:px(31, 41, P.wood.hi) c:px(32, 41, P.wood.hi)
c:px(31, 42, P.wood.shade) c:px(32, 42, P.wood.shade)
for _, p in ipairs({ { 29, 45 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 33, 45 } }) do c:px(p[1], p[2], P.ink) end

M.done(c, "ss-palm-fidget-yard")
