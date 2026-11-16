-- Stilt Stoop (mt-stilt-stoop), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: a waving arm raised beside the moss hat.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-stilt-stoop-perch", 36)

c:part(c:ellipse(18, 33, 8, 1), "sea", { noshade = true })
c:part(c:line({ { 15, 22 }, { 14, 32 } }, 1), "wood")
c:part(c:line({ { 21, 22 }, { 22, 32 } }, 1), "wood")
c:part(c:line({ { 24, 17 }, { 29, 9 } }, 1), "skinA")
c:px(29, 8, P.skinA.base) c:px(30, 8, P.skinA.base)
c:part(c:ellipse(18, 18, 8, 7), "gold", { band = 2 })
c:part(c:ellipse(18, 12, 4, 4), "moss", { band = 1 })
c:part(c:rect(12, 14, 24, 15), "moss")
c:eyeSmall(14, 17)
c:eyeSmall(20, 17)
c:px(17, 21, P.ink) c:px(18, 21, P.ink)

M.done(c, "mt-stilt-stoop-perch")
