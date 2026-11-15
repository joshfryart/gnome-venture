-- Bill Brolly (mt-bill-brolly), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: a big moss leaf umbrella over a hornbill with a gold beak.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-bill-brolly-perch", 36)

c:part(c:line({ { 18, 10 }, { 18, 12 } }, 1), "wood")
c:part(c:ellipse(18, 6, 12, 4), "moss", { band = 2 })
c:fillMask(c:line({ { 7, 6 }, { 29, 6 } }, 1), P.moss.deep)
c:part(c:ellipse(14, 23, 6, 7), "dusk", { band = 2 })
c:part(c:ellipse(14, 25, 3, 4), "stone", { noshade = true })
c:part(c:ellipse(14, 15, 5, 5), "dusk", { band = 1 })
c:part(c:poly{ { 18, 13 }, { 27, 16 }, { 18, 18 } }, "gold")
c:fillMask(c:rect(18, 12, 19, 13), P.ember.base)
c:eyeSmall(11, 13)
c:eyeSmall(15, 13)
c:part(c:line({ { 12, 30 }, { 12, 33 } }, 1), "gold")
c:part(c:ellipse(6, 31, 2, 1), "moss", { noshade = true })

M.done(c, "mt-bill-brolly-perch")
