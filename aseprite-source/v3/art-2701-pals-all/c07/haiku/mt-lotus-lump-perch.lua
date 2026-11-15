-- Lotus Lump (mt-lotus-lump), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: a notched lotus pad under a sleeping pink lump.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-lotus-lump-perch", 36)

local pad = c:ellipse(18, 29, 12, 3)
pad:cut(c:poly{ { 18, 29 }, { 24, 27 }, { 24, 31 } })
c:part(pad, "moss", { noshade = true })
c:part(c:poly{ { 17, 16 }, { 18, 10 }, { 21, 16 } }, "petal")
c:part(c:ellipse(18, 22, 8, 7), "petal", { band = 2 })
c:eyeSmall(14, 20)
c:eyeSmall(20, 20)
c:fillMask(c:rect(14, 20, 15, 20), P.petal.deep)
c:fillMask(c:rect(20, 20, 21, 20), P.petal.deep)
c:px(17, 25, P.ink)
c:px(6, 10, P.sea.base) c:px(29, 8, P.sea.base) c:px(30, 16, P.sea.base)

M.done(c, "mt-lotus-lump-perch")
