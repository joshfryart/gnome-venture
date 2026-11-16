-- Clownfish Peek (pl-bjq-2), yard 64x64. Common, rootwarden. An orange striped fish peeking out of pink coral.
-- quirk: the coral mound hides the fish's bottom half, so it looks like it just popped out to check on you.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-bjq-2-yard", 64), H.P
c:part(c:poly{ {46,28},{60,16},{58,40} }, "gold")
local body = c:ellipse(30, 26, 15, 10)
c:part(body, "ember", { sep = true })
c:fillMask(body:copy():clip(c:rect(22, 14, 25, 38)), P.cream)
c:fillMask(body:copy():clip(c:rect(34, 14, 37, 38)), P.cream)
c:eyeLocked(18, 22)
c:cheek(21, 29)
c:part(c:ellipse(32, 62, 30, 30), "petal", { sep = true })
c:part(c:line({ {12,50},{10,38},{14,30} }, 5), "petal", { sep = true })
c:part(c:line({ {52,50},{54,38},{48,30} }, 5), "petal", { sep = true })
H.done(c, "pl-bjq-2-yard")
