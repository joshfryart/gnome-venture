-- Tentacle Wisp (pl-bjq-1), yard 64x64. Common, seedkeeper. A pink bulb head on a swaying tentacle.
-- quirk: little ink music notes float off its head; it sways to a tune nobody else can hear.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local c, P = H.canvas("pl-bjq-1-yard", 64), H.P
c:part(c:line({ {30,30},{38,38},{28,44},{20,50},{30,58},{42,56},{46,48} }, 6), "petal", { sep = true })
c:part(c:line({ {46,48},{54,42},{50,36} }, 3), "petal", { sep = true })
c:part(c:ellipse(30, 22, 12, 11), "petal", { sep = true })
c:eyeLocked(23, 18)
c:eyeLocked(34, 18)
c:cheek(20, 24)
c:cheek(40, 24)
for _, p in ipairs({ {30,26},{31,27},{32,27},{33,26} }) do c:px(p[1], p[2], P.ink) end
c:fillMask(c:rect(49, 10, 50, 11), P.ink)
c:fillMask(c:line({ {50,9},{50,2} }, 1), P.ink)
c:fillMask(c:line({ {50,2},{53,4} }, 1), P.ink)
H.done(c, "pl-bjq-1-yard")
