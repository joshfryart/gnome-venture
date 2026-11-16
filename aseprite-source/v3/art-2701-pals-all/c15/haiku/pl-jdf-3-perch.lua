-- Jade Shimmer (pl-jdf-3), perch 36x36. Hand-drawn at size. Sits on the wooden perch.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-jdf-3-perch", 36), H.P
H.ledge(c)
local body = c:poly{ {18,4},{27,8},{31,18},{27,28},{18,31},{9,28},{5,18},{9,8} }
c:part(body:copy():clip(c:rect(0, 0, 17, 35)), "sea")
c:part(body:copy():clip(c:rect(18, 0, 35, 35)), "moss")
c:eyeSmall(13, 14)
c:eyeSmall(21, 14)
for _, p in ipairs({ {15,20},{16,21},{17,21},{18,21},{19,20} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(3, 6)
c:sparkle(32, 5)
H.done(c, "pl-jdf-3-perch")
