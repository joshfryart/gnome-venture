-- hat-seedkeeper (dC11 first draft): blue hat, wide round brim, tip hooking right and ending in a gold seed pendant; band with a little seed pouch.
-- quirk: a sunflower seed is tucked behind the brim.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hat-seedkeeper")
local P = D.P
local brim = D.ell(32, 50, 24, 7)
D.part(c, brim, D.r4("#9fd6f0", "#3f86c0", "#2c5a99", "#1e3366"), 3)
local m, T = D.H.sweep({ {32,50},{30,32},{36,14},{48,12} }, function(t) return 12 * (1 - t) ^ 0.8 + 0.8 end, 90)
m:clip(c:rect(0, 0, 63, 50))
D.part(c, m, D.r4("#9fd6f0", "#3f86c0", "#2c5a99", "#1e3366"), 4)
local bm = D.HP.mask() m:each(function(x, y) if y >= 42 and y <= 46 then bm:set(x, y) end end)
D.part(c, bm, "wood", 2)
-- pouch
D.part(c, D.ell(32, 43, 4, 3.5), D.r4("#ffe38a", "#f5b82e", "#d98322", "#8f4a1f"), 2)
c:px(32, 40, P.wood.deep) c:px(31, 40, P.gold.shade) c:px(33, 40, P.gold.shade)
-- pendant
D.ln(c, 48, 12, 50, 16, P.gold.shade)
D.part(c, D.ell(51, 19, 2.4, 3.2, 0.2), "gold", 2)
c:px(50, 17, P.cream)
-- tucked sunflower seed
D.part(c, D.ell(14, 49, 1.6, 3.2, 0.5), D.r4("#e2e0e6", "#6a6c7a", "#444663", "#2b1c26"), 1)
c:px(14, 48, P.cream)
D.fin()
