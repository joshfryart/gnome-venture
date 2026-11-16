-- Tide Tuck (ss-tide-tuck), perch 36x36, hand-built at size. Haiku first pass, c00.
-- quirk: foam curl on the wave crest behind it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("ss-tide-tuck-perch", 36)

c:part(c:poly{ { 1, 34 }, { 1, 27 }, { 6, 22 }, { 12, 20 }, { 18, 23 }, { 24, 19 }, { 32, 22 }, { 35, 28 }, { 35, 34 } }, "sea")
c:fillMask(c:line({ { 12, 20 }, { 15, 17 }, { 20, 18 } }, 1), P.cream)
local sand = c:ellipse(18, 26, 11, 8)
sand:cut(c:rect(0, 32, 35, 35))
c:part(sand, "gold", { band = 2 })
c:eyeSmall(13, 25)
c:eyeSmall(21, 25)
c:px(17, 27, P.gold.hi) c:px(18, 27, P.gold.hi)
c:px(15, 28, P.ink) c:px(16, 29, P.ink) c:px(17, 29, P.ink) c:px(18, 29, P.ink) c:px(19, 28, P.ink)

M.done(c, "ss-tide-tuck-perch")
