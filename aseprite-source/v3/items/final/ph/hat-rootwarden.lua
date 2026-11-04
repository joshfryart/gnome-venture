-- hat-rootwarden (dC11 first draft): earthy brown hat, tip drooping left with two sprout leaves, rope-root band, tangled root fringe under the brim.
-- quirk: a pink worm peeks out of the band.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hat-rootwarden")
local P = D.P
local brim = D.ell(32, 49, 23, 6)
D.part(c, brim, "wood", 3)
-- roots hanging
for _, r in ipairs{ {13,53,2},{18,55,3},{26,56,2},{39,56,3},{46,55,2},{51,53,2} } do
  D.ln(c, r[1], r[2], r[1] + (r[3] - 2), r[2] + r[3], P.wood.deep)
end
local m, T = D.H.sweep({ {32,48},{35,34},{30,18},{15,22} }, function(t) return 13 * (1 - t) ^ 0.9 + 0.8 end, 90)
m:clip(c:rect(0, 0, 63, 49))
D.part(c, m, "wood", 4)
-- bark texture on cone
m:each(function(x, y) if (x * 5 + y * 3) % 9 == 0 and T[D.K(x, y)] and T[D.K(x, y)] > 0.1 then c:px(x, y, P.wood.shade) end end)
-- band of twisted rope
local bm = D.HP.mask() m:each(function(x, y) if y >= 41 and y <= 45 then bm:set(x, y) end end)
D.part(c, bm, "gold", 1)
bm:each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, P.gold.deep) end end)
-- sprout leaves at tip
D.part(c, D.ell(13, 18, 4, 2, -0.7), "moss", 2) D.part(c, D.ell(18, 15, 4, 2, -0.2), "moss", 2)
D.ln(c, 15, 22, 15, 19, P.moss.shade)
-- worm
for i = 0, 5 do c:px(36 + i, 43 + (i % 2), "#ee9a9a") end
c:px(41, 43, P.ink) c:px(36, 42, "#f7c4c4")
D.fin()
