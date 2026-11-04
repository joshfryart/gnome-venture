-- hazelnut (dC11 first draft): glossy chestnut-brown nut with fine vertical striping, pale scar at the base, frilled green husk cap on a short stalk.
-- quirk: a squirrel has taken one bite out of the lower right, showing the cream kernel.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC11.lua")
local c = D.new("hazelnut")
local P = D.P
c:groundShadow(32, 57, 13, 2)
local NUT = D.r4("#e8b982", "#b97a4a", "#864c33", "#51302b")
local body = D.ell(31, 40, 13, 14)
local bite = D.ell(43, 50, 6, 6)
body:cut(bite)
D.part(c, body, NUT, 6)
body:each(function(x, y) if (x % 4 == 1) and y > 30 then c:px(x, y, (x < 31) and NUT[4] or NUT[2]) end end)
-- kernel in bite
local ker = D.ell(43, 50, 6, 6):clip(D.ell(31, 40, 15, 16))
ker:cut(body)
D.part(c, ker, D.r4("#fffaf0", "#f4e3b8", "#d6b98a", "#8f6e55"), 2)
c:px(41, 47, P.cream)
-- scar
c:fillMask(D.ell(28, 52, 4, 1.8), "#e8d2a2") c:px(27, 52, "#fff4d6")
-- husk cap with frill
local cap = D.ell(31, 29, 13, 7):add(c:poly{ {20,31},{42,31},{39,35},{23,35} })
for i = 0, 6 do cap:cut(c:poly{ {19 + i * 4, 36},{21 + i * 4, 36},{20 + i * 4, 32} }) end
D.part(c, cap, "moss", 3)
cap:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, P.moss.shade) end end)
for _, x in ipairs{ 24, 31, 38 } do D.ln(c, x, 34, x, 30, P.moss.deep) end
-- stalk
D.ln(c, 31, 23, 33, 17, P.moss.shade) D.ln(c, 32, 23, 34, 17, P.moss.base) c:px(34, 16, P.moss.hi)
D.fin()
