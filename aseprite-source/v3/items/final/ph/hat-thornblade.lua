-- hat-thornblade (dC11 first draft): sharp crimson hat, narrow and raked back to a needle tip, spiked brim like a rose stem.
-- quirk: one tiny rosebud grows from the band.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hat-thornblade")
local P = D.P
local brim = D.ell(32, 51, 20, 4.5)
D.part(c, brim, "ember", 3)
-- thorns on the brim edge
for _, t in ipairs{ {12,51},{18,55},{27,57},{37,57},{46,55},{52,51} } do
  c:poly{ {t[1]-2,t[2]-1},{t[1]+2,t[2]-1},{t[1],t[2]+3} }:each(function(x, y) c:px(x, y, P.stone.base) end)
  c:px(t[1], t[2] + 2, P.stone.hi)
end
local m, T = D.H.sweep({ {30,50},{30,38},{36,20},{50,4} }, function(t) return 10 * (1 - t) ^ 0.95 + 0.6 end, 90)
m:clip(c:rect(0, 0, 63, 51))
D.part(c, m, "ember", 4)
local bm = D.HP.mask() m:each(function(x, y) if y >= 43 and y <= 46 then bm:set(x, y) end end)
D.part(c, bm, D.r4("#9aa0b0", "#555a70", "#3a3d55", "#232538"), 1)
for x = 25, 38, 4 do c:px(x, 42, P.stone.hi) c:px(x, 41, P.stone.base) end
-- rosebud
D.part(c, D.ell(37, 44, 3, 3), "petal", 2) c:px(36, 43, P.petal.hi) c:px(37, 45, P.petal.deep)
c:px(34, 45, P.moss.base) c:px(35, 46, P.moss.shade) c:px(39, 46, P.moss.base)
D.fin()
