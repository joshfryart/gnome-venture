-- trail-wonder (32x32 trail map marker, Haiku first pass). Two tall standing stones and a lintel make a ring-arch
-- with a violet glow inside, a gold rune down the left stone and cream star sparkles in the sky.
-- quirk: a tuft of moss has grown along the top of the lintel.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-wonder")

c:groundShadow(16, 27, 12, 2)
c:part(c:rect(6, 9, 11, 26), "stone")
c:part(c:rect(20, 9, 25, 26), "stone")
T.fill(c, c:rect(12, 10, 19, 26), "#8a6fd0")
T.fill(c, c:rect(12, 10, 19, 14), "#c9b2f0")
T.fill(c, c:rect(12, 24, 19, 26), "#5a459e")
c:part(c:rect(4, 6, 27, 9), "stone")
local rune = c:line({ { 8, 12 }, { 8, 22 } }, 1)
T.fill(c, rune, "#ffe38a")
T.fill(c, c:line({ { 6, 14 }, { 10, 14 } }, 1), "#ffe38a")
T.fill(c, c:line({ { 6, 18 }, { 10, 18 } }, 1), "#ffe38a")
for _, p in ipairs{ { 7, 6 }, { 8, 6 }, { 13, 5 }, { 14, 5 }, { 21, 5 }, { 22, 6 } } do c:put(p[1], p[2], "#7cc35a") end
c:put(7, 5, "#9cd27a") c:put(21, 4, "#7cc35a")
c:sparkle(27, 14)
c:sparkle(3, 4)
T.done(c)
