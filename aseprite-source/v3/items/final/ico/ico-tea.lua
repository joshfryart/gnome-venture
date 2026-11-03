local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tea: cream ceramic teacup with a looped handle, green tea, resting on a saucer, steam curling up.
-- quirk: the tea bag's string and a red paper tag hang over the cup's rim.
local c = D.new("ico-tea")
c:groundShadow(30, 57, 26, 2)
D.lit(c, D.ell(30, 52, 24, 5), D.CRM, 5, { amb = 0.15 })
D.rect(c, 8, 51, 52, 52, D.CRM[3])
local cup = D.ell(30, 36, 20, 17):clip(c:rect(0, 28, 63, 60)):add(c:rect(10, 28, 50, 34)) cup:clip(c:rect(0, 28, 63, 50))
D.lit(c, cup, D.CRM, 10, { amb = 0.1 })
D.rect(c, 10, 29, 50, 30, D.CRM[2]) D.rect(c, 20, 47, 40, 49, D.CRM[1])
local hd = D.ell(51, 38, 8, 8) hd:cut(D.ell(51, 38, 4, 4)) hd:cut(c:rect(0, 0, 46, 63)) D.lit(c, hd, D.CRM, 3)
local tea = D.ell(30, 29, 17, 3.5) D.lit(c, tea, D.GRN, 3, { amb = 0.2 }) c:px(24, 28, D.GRN[6]) c:px(25, 28, D.GRN[6])
D.rect(c, 12, 29, 48, 29, D.GRN[2])
-- tag
D.ln(c, 36, 28, 41, 23, D.CRM[2]) D.ln(c, 41, 23, 44, 32, D.CRM[2]) D.rect(c, 42, 33, 46, 37, D.RED[4]) c:px(42, 33, D.RED[6])
-- steam
for i = 0, 8 do local y = 22 - i * 2 c:px(floor(26 + sin(i * .8) * 2 + .5), y, D.CRM[5]) c:px(floor(27 + sin(i * .8) * 2 + .5), y, D.CRM[5]) end
for i = 0, 6 do local y = 20 - i * 2 c:px(floor(34 + sin(i * .8 + 2) * 2 + .5), y, D.CRM[4]) c:px(floor(35 + sin(i * .8 + 2) * 2 + .5), y, D.CRM[4]) end
D.fin()
