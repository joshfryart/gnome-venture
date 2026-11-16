-- Tentacle Wisp (pl-bjq-1), perch 36x36. Hand-drawn at size: pink head, short curl, perched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-bjq-1-perch", 36), H.P
H.ledge(c)
c:part(c:line({ {14,15},{18,20},{12,24},{10,27},{16,31} }, 3), "petal", { sep = true })
c:part(c:ellipse(16, 11, 7, 6), "petal", { sep = true })
c:eyeSmall(13, 10)
c:eyeSmall(19, 10)
c:px(15, 14, P.ink)
c:px(16, 14, P.ink)
c:fillMask(c:rect(26, 5, 27, 6), P.ink)
c:fillMask(c:line({ {27,4},{27,1} }, 1), P.ink)
H.done(c, "pl-bjq-1-perch")
