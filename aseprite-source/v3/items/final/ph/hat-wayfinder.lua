-- hat-wayfinder (dC11 first draft): green ranger hat, snug round-edged brim, tip topped with a tiny pennant, brass compass badge, feather in the band.
-- quirk: the compass needle points the wrong way (at a pie).
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hat-wayfinder")
local P = D.P
local brim = D.ell(32, 50, 21, 6)
D.part(c, brim, "moss", 3)
local m, T = D.H.sweep({ {32,50},{34,34},{30,20},{36,10} }, function(t) return 12 * (1 - t) ^ 0.75 + 0.8 end, 90)
m:clip(c:rect(0, 0, 63, 50))
D.part(c, m, "moss", 4)
local bm = D.HP.mask() m:each(function(x, y) if y >= 44 and y <= 48 then bm:set(x, y) end end)
D.part(c, bm, "wood", 1)
-- compass
D.part(c, D.ell(33, 36, 5, 5), "gold", 3)
c:fillMask(D.ell(33, 36, 3, 3), P.cream)
c:px(33, 34, P.ember.base) c:px(33, 35, P.ember.base) c:px(33, 37, P.stone.shade) c:px(33, 38, P.stone.shade) c:px(32, 36, P.ink) c:px(34, 36, P.ink)
-- feather
D.part(c, D.ell(45, 42, 1.8, 5, 0.5), "ember", 1) D.ln(c, 42, 47, 47, 38, P.ink)
-- pennant
D.ln(c, 36, 10, 36, 2, P.ink)
c:poly{ {37,2},{44,4},{37,7} }:each(function(x, y) c:px(x, y, P.ember.base) end) c:px(38, 3, P.ember.hi)
D.fin()
