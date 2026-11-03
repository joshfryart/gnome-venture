local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-squirrel: sitting squirrel in profile (faces left) with a huge S-curled tail, tufted ear, cream belly.
-- quirk: it clutches an acorn nearly as big as its own paws.
local c = D.new("ico-squirrel")
local tail = D.sweep({ {34,54},{62,52},{58,14},{38,10} }, function(t) return 6 - 1.5 * abs(t - 0.5) end, 60)
D.lit(c, tail, D.BRN, 6, { amb = 0.1 })
for t = 0, 1, 0.07 do local u = 1 - t local x = u^3*34 + 3*u*u*t*62 + 3*u*t*t*58 + t^3*38 local y = u^3*54 + 3*u*u*t*52 + 3*u*t*t*14 + t^3*10 c:px(floor(x + .5) - 1, floor(y + .5), D.BRN[6]) end
local body = D.ell(30, 42, 11, 14) D.lit(c, body, D.BRN, 8, { amb = 0.1 })
D.lit(c, D.ell(26, 44, 6, 9), D.CRM, 4, { amb = 0.2 })
D.lit(c, c:rect(22, 54, 38, 57), D.BRN, 3)
local head = D.ell(24, 22, 9, 8) D.lit(c, head, D.BRN, 6, { amb = 0.1 })
c:fillMask(c:poly{ {26,14},{28,6},{32,15} }, D.BRN[3]) c:px(28, 9, D.BRN[1]) c:px(28, 8, D.BRN[1])
D.rect(c, 17, 24, 20, 27, D.CRM[4])
c:eyeSmall(20, 18)
D.rect(c, 15, 22, 16, 23, D.INK) c:px(15, 22, D.CRM[6])
-- acorn
D.lit(c, D.ell(23, 42, 4, 4), D.TAN, 3) D.rect(c, 19, 38, 27, 39, D.BRN[3]) c:px(23, 36, D.BRN[1])
D.rect(c, 21, 44, 26, 46, D.SKIN[3])
D.fin()
