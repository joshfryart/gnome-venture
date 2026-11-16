-- Bell Bead (pl-bjq-3), yard 64x64. Common, bloomcaller. A tiny blue bell with a gold clapper.
-- quirk: little cream sound ticks on both sides ring out when the queen is near.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-bjq-3-yard", 64), H.P
c:part(c:line({ {32,18},{32,9} }, 2), "stone")
c:part(c:ellipse(32, 8, 4, 4), "stone", { sep = true })
c:part(c:poly{ {24,18},{40,18},{46,30},{48,46},{16,46},{18,30} }, "sea", { sep = true })
c:part(c:rrect(12, 44, 52, 50, 3), "sky", { sep = true })
c:part(c:ellipse(32, 56, 4, 4), "gold")
c:eyeLocked(24, 28)
c:eyeLocked(36, 28)
c:cheek(21, 36)
c:cheek(41, 36)
for _, p in ipairs({ {30,37},{31,38},{32,38},{33,37} }) do c:px(p[1], p[2], P.ink) end
c:fillMask(c:line({ {9,24},{7,32} }, 1), P.cream)
c:fillMask(c:line({ {55,24},{57,32} }, 1), P.cream)
H.done(c, "pl-bjq-3-yard")
