-- Stitch Crow (mh-stitch-crow), perch 36x36, hand-built at size. Haiku first pass, c00.
-- quirk: cream measuring tape hanging round its neck.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-stitch-crow-perch", 36)

c:groundShadow(18, 33, 8, 2)
c:part(c:poly{ { 14, 26 }, { 8, 33 }, { 13, 34 }, { 19, 29 } }, "dusk")
c:part(c:ellipse(18, 25, 8, 7), "dusk")
c:part(c:ellipse(18, 16, 6, 5), "dusk")
c:part(c:poly{ { 23, 16 }, { 27, 17 }, { 23, 18 } }, "gold")
c:part(c:rrect(12, 4, 24, 10, 2), "gold")
c:part(c:ellipse(18, 11, 10, 2), "gold")
c:fillMask(c:rect(12, 9, 24, 9), P.ember.base)
c:eyeSmall(14, 15)
c:eyeSmall(20, 15)
c:px(24, 17, P.cream)
c:fillMask(c:line({ { 14, 21 }, { 15, 26 }, { 18, 30 } }, 1), P.cream)
c:px(14, 23, P.ink) c:px(16, 28, P.ink)

M.done(c, "mh-stitch-crow-perch")
