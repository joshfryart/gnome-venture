-- Lantern Eye Pair (pl-jdf-5), yard 64x64. Uncommon, rootwarden. A dusk-iron lantern with a gold window and two locked eyes.
-- quirk: the eyes throw a glint whenever the dragonfly flies past.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-jdf-5-yard", 64), H.P
c:part(c:line({ {22,16},{32,5},{42,16} }, 2), "stone")
c:part(c:rrect(14, 14, 49, 56, 6), "dusk")
c:part(c:rrect(18, 18, 45, 52, 4), "gold")
c:part(c:rect(20, 56, 43, 60), "wood")
c:eyeLocked(21, 26)
c:eyeLocked(38, 26)
c:cheek(21, 36)
c:cheek(41, 36)
for _, p in ipairs({ {29,40},{30,41},{31,41},{32,41},{33,40} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(6, 22)
c:sparkle(57, 44)
c:sparkle(10, 52)
H.done(c, "pl-jdf-5-yard")
