local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-sunflower: big sunflower head, ring of yellow petals round a brown seed disc, green stem and two leaves.
-- quirk: a small bumblebee rests on a petal on the left.
local c = D.new("ico-sunflower")
D.cyl(c, 32, 38, 32, 60, function() return 2 end, D.GRN, { amb = 0.1 })
D.leaf(c, 32, 54, 52, 44, 5, D.GRN, { 6 }) D.leaf(c, 32, 50, 12, 42, 5, D.GRN, { 6 })
for i = 0, 11 do
  local a = i * pi / 6 local ux, uy = cos(a), sin(a)
  local m = D.ell(32 + ux * 14, 26 + uy * 14, 6.5, 3.4, a)
  D.lit(c, m, D.YEL, 3, { amb = 0.15 })
end
D.disc(c, 32, 26, 9, D.BRN)
for a = 0, 5 do local t = a * 1.05 c:px(floor(32 + cos(t) * 5 + .5), floor(26 + sin(t) * 5 + .5), D.BRN[2]) end
c:px(29, 22, D.BRN[6]) c:px(30, 22, D.BRN[6]) c:px(33, 28, D.BRN[2]) c:px(32, 26, D.BRN[1]) c:px(35, 25, D.BRN[6]) c:px(28, 27, D.BRN[2])
-- bee
D.rect(c, 5, 22, 11, 26, D.YEL[4]) D.rect(c, 7, 22, 7, 26, D.INK) D.rect(c, 10, 22, 10, 26, D.INK) D.rect(c, 6, 20, 8, 21, D.CRM[5]) D.rect(c, 3, 25, 4, 25, D.INK)
D.fin()
