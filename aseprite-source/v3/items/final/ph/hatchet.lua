-- hatchet (dC11 first draft): slim hickory handle with a leather grip, small steel head with a bright bevelled edge and a dark eye.
-- quirk: a little acorn charm dangles from a cord on the handle end.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hatchet")
local P = D.P
local STEEL = D.r4("#f2f4fa", "#aab0c4", "#6f7490", "#3a3d58")
local hm, T, S = D.H.cyl(c, 15, 56, 41, 19, function(t) return 1.7 + (1 - t) * 0.9 end, "wood")
-- grain
hm:each(function(x, y) if (x * 2 + y) % 7 == 0 then c:px(x, y, P.wood.shade) end end)
-- leather grip
hm:each(function(x, y) if y > 42 and y < 55 then c:px(x, y, ((x + y) % 3 == 0) and "#5e3a2e" or "#864c33") end end)
-- head
local head = c:poly{ {37,13},{47,10},{56,5},{58,19},{55,33},{46,28},{37,25} }
D.part(c, head, STEEL, 5)
-- bevel edge
head:each(function(x, y) if x >= 55 and y > 7 and y < 32 then c:px(x, y, P.cream) end end)
c:px(55, 12, "#ffffff" == "x" and P.cream or P.cream)
-- eye hole
c:fillMask(c:rect(40, 17, 42, 20), "#2a2a44")
c:px(40, 17, STEEL[3])
-- acorn charm
D.ln(c, 15, 56, 11, 58, P.gold.shade)
D.part(c, D.ell(10, 60, 2.4, 2.4), "wood", 2) c:fillMask(c:rect(8, 57, 12, 58), P.wood.deep)
D.fin()
