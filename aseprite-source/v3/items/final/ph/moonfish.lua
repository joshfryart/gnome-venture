-- moonfish: round silver-blue moon-disc fish, crescent moon mark on its flank, crescent tail. quirk: bubble holding a star.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local floor = math.floor
local H, HP, B = D.H, D.HP, D.B
local c = D.new("moonfish")
local BODY = D.R("#e4f2ff", "#8fb8e8", "#5a78c0", "#33396e")
local FIN = D.R("#ffb28a", "#ee5e4a", "#b8343e", "#6e2038")
local tail = c:poly{ {42,32}, {52,18}, {57,16}, {53,32}, {57,48}, {52,46} }
B.lit(c, tail, FIN, 2)
B.ln(c, 43, 32, 54, 20, "#ffb28a", tail) B.ln(c, 43, 32, 54, 32, "#b8343e", tail) B.ln(c, 43, 32, 54, 44, "#ffb28a", tail)
local dors = c:poly{ {22,17}, {30,9}, {40,15}, {38,20} }
B.lit(c, dors, FIN, 2)
local body = c:ellipse(27, 32, 18, 15)
B.lit(c, body, BODY, 8)
-- scales
body:each(function(x, y) if (x + y * 2) % 5 == 0 and (y % 2 == 0) and x > 20 then c:px(x, y, "#b4d0f2") end end)
-- belly stripe
for x = 14, 36 do local y = 44 - floor((x - 25) ^ 2 / 44) if body:has(x, y) then c:px(x, y, "#5a78c0") end end
-- moon crescent
local moon = c:ellipse(26, 28, 6, 6):cut(c:ellipse(29, 27, 5, 5))
c:fillMask(moon, "#fff4d6")
c:px(23, 30, "#ffe38a")
-- fin
local fin = B.ell(31, 38, 4.5, 2.4, 0.6)
B.lit(c, fin, FIN, 1.8)
-- face
c:eyeSmall(14, 27)
c:px(11, 35, "#6e2038") c:px(12, 36, "#6e2038") c:px(13, 36, "#6e2038")
-- bubble with a star
local bub = c:ellipse(9, 14, 4, 4)
c:fillMask(bub, "#b6f0e0") c:fillMask(bub:shrink(1), "#e4f6ff")
c:px(9, 12, "#f5b82e") c:px(9, 14, "#f5b82e") c:px(8, 13, "#f5b82e") c:px(10, 13, "#f5b82e") c:px(9, 13, "#ffe38a") c:px(7, 11, "#fff4d6")
D.fin()
