-- Seedling Plod (mt-seedling-plod), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: a sprouting seedling on its head and a sea-blue note.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-seedling-plod-perch", 36)

c:part(c:ellipse(14, 31, 3, 2), "wood")
c:part(c:ellipse(22, 31, 3, 2), "wood")
c:part(c:ellipse(18, 21, 9, 9), "moss", { band = 2 })
c:part(c:line({ { 18, 12 }, { 18, 8 } }, 1), "moss")
c:part(c:poly{ { 18, 10 }, { 14, 6 }, { 13, 9 }, { 17, 12 } }, "gold")
c:part(c:poly{ { 19, 9 }, { 23, 5 }, { 24, 8 }, { 20, 11 } }, "gold")
c:eyeSmall(14, 19)
c:eyeSmall(20, 19)
c:px(17, 23, P.ink) c:px(18, 23, P.ink)
c:fillMask(c:rect(28, 8, 29, 12), P.sea.base)
c:px(30, 7, P.sea.base)

M.done(c, "mt-seedling-plod-perch")
