-- hat-bloomcaller (dC11 first draft): soft pink hat, tip drooping right into a closed flower bud, scalloped petal brim, band of three daisies.
-- quirk: a bee has landed on the bud.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hat-bloomcaller")
local P = D.P
local brim = D.ell(32, 51, 22, 5)
for a = 0, 6 do local x = 32 + math.cos(a * 0.9 - 0.2) * 20 brim:add(D.ell(x, 51 + math.sin(a * 0.9 - 0.2) * 3, 4, 3.2)) end
D.part(c, brim, "petal", 3)
local m, T = D.H.sweep({ {32,50},{29,30},{34,14},{50,22} }, function(t) return 11 * (1 - t) ^ 0.8 + 0.8 end, 90)
m:clip(c:rect(0, 0, 63, 51))
D.part(c, m, "petal", 4)
-- band
local band = HP and nil
local bm = D.HP.mask() m:each(function(x, y) if y >= 41 and y <= 46 then bm:set(x, y) end end)
D.part(c, bm, "ember", 2)
for _, x in ipairs{ 23, 32, 41 } do
  for _, o in ipairs{ {0,-1},{0,1},{-1,0},{1,0} } do c:px(x + o[1] * 2, 44 + o[2] * 2 - (o[2] ~= 0 and 0 or 0), P.cream) end
  c:fillMask(c:rect(x - 1, 43, x + 1, 45), P.cream) c:px(x, 44, P.gold.base)
end
-- bud
D.part(c, D.ell(51, 25, 4, 5, 0.3), "ember", 3)
c:px(50, 21, P.moss.base) c:px(52, 21, P.moss.base) c:px(51, 29, P.moss.shade)
-- bee
c:fillMask(c:rect(46, 17, 50, 19), P.gold.base) c:px(47, 17, P.ink) c:px(49, 17, P.ink) c:px(45, 16, P.cream) c:px(46, 15, P.cream) c:px(49, 15, P.cream)
D.fin()
