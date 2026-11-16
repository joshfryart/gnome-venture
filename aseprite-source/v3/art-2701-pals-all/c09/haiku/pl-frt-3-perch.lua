-- Thawdrop Pip (pl-frt-3), perch sprite 36x36, hand-built at this size. Quirk: small yawn mouth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-3-perch", 36)

c:groundShadow(18, 31, 7, 1.5)
local body = c:ellipse(18, 22, 8, 8)
body:add(c:poly{ { 18, 9 }, { 11, 21 }, { 25, 21 } })
c:part(body, "sea")
c:eyeSmall(14, 20)
c:eyeSmall(20, 20)
c:fillMask(c:ellipse(18, 27, 1.5, 1), P.ink)
c:sparkle(24, 15)
H.save(c, "pl-frt-3-perch")
