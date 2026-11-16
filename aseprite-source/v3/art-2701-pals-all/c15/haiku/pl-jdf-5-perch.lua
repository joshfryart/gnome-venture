-- Lantern Eye Pair (pl-jdf-5), perch 36x36. Hand-drawn at size: small lantern with two eyes, on the perch.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-jdf-5-perch", 36), H.P
H.ledge(c)
c:part(c:line({ {12,8},{18,3},{24,8} }, 1), "stone")
c:part(c:rrect(8, 7, 27, 28, 3), "dusk")
c:part(c:rrect(10, 9, 25, 26, 2), "gold")
c:part(c:rect(12, 29, 23, 30), "wood")
c:eyeSmall(12, 14)
c:eyeSmall(21, 14)
for _, p in ipairs({ {15,20},{16,21},{17,21},{18,20} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(3, 12)
H.done(c, "pl-jdf-5-perch")
