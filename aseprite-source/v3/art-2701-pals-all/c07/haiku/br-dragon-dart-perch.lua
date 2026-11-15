-- Dragon Dart (br-dragon-dart), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: two big paper wings with a petal-coloured upper pair.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("br-dragon-dart-perch", 36)

c:part(c:poly{ { 16, 14 }, { 4, 6 }, { 2, 13 }, { 14, 20 } }, "petal")
c:part(c:poly{ { 20, 14 }, { 32, 6 }, { 34, 13 }, { 22, 20 } }, "petal")
c:part(c:poly{ { 16, 20 }, { 8, 22 }, { 9, 27 }, { 16, 25 } }, "sky")
c:part(c:poly{ { 20, 20 }, { 28, 22 }, { 27, 27 }, { 20, 25 } }, "sky")
c:part(c:rect(17, 13, 19, 27), "sea")
c:part(c:rect(17, 28, 19, 33), "sea")
c:px(18, 34, P.sea.deep)
c:part(c:ellipse(18, 11, 4, 3), "moss", { band = 1 })
c:eyeSmall(15, 10)
c:eyeSmall(19, 10)
c:px(17, 13, P.ink) c:px(18, 13, P.ink)

M.done(c, "br-dragon-dart-perch")
