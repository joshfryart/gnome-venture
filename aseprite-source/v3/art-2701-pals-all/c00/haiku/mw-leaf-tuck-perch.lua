-- Leaf Tuck (mw-leaf-tuck), perch 36x36, hand-built at size. Haiku first pass, c00.
-- quirk: tucked flap with moss underside, leaf stalk on top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mw-leaf-tuck-perch", 36)

c:groundShadow(18, 33, 8, 2)
c:part(c:line({ { 18, 5 }, { 19, 2 } }, 1), "moss")
c:part(c:poly{ { 18, 4 }, { 24, 9 }, { 27, 15 }, { 26, 23 }, { 20, 30 }, { 18, 31 }, { 16, 30 }, { 10, 23 }, { 9, 15 }, { 12, 9 } }, "ember")
c:part(c:poly{ { 23, 11 }, { 26, 16 }, { 26, 23 }, { 23, 26 }, { 22, 19 } }, "moss", { band = 2 })
c:eyeSmall(13, 17)
c:eyeSmall(21, 17)
c:px(17, 20, P.ember.hi) c:px(18, 20, P.ember.hi)
c:px(16, 23, P.ink) c:px(17, 24, P.ink) c:px(18, 24, P.ink) c:px(19, 23, P.ink)

M.done(c, "mw-leaf-tuck-perch")
