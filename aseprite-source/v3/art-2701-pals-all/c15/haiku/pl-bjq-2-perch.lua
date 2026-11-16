-- Clownfish Peek (pl-bjq-2), perch 36x36. Hand-drawn at size: a striped fish peeking over a coral clump on the perch.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-bjq-2-perch", 36), H.P
c:part(c:poly{ {24,15},{31,10},{31,24} }, "gold")
local body = c:ellipse(16, 16, 9, 6)
c:part(body, "ember", { sep = true })
c:fillMask(body:copy():clip(c:rect(12, 8, 13, 24)), P.cream)
c:fillMask(body:copy():clip(c:rect(19, 8, 20, 24)), P.cream)
c:eyeSmall(9, 14)
c:part(c:ellipse(18, 40, 16, 20), "petal", { sep = true })
c:part(c:line({ {4,34},{3,26},{6,20} }, 3), "petal", { sep = true })
H.done(c, "pl-bjq-2-perch")
