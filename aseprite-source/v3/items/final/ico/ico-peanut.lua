local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-peanut: fat figure-eight shell laid diagonally with a net of tiny pits.
-- quirk: one end is cracked open and a pale nut peeks out of the split.
local c = D.new("ico-peanut")
c:groundShadow(32, 57, 14, 2)
local sh = D.ell(24, 41, 11, 10, 0.4):add(D.ell(40, 24, 10, 9, 0.4)):add(D.ell(32, 32.5, 7, 7, 0.6))
D.lit(c, sh, D.TAN, 8, { amb = 0.08 })
sh:each(function(x, y)
  if (x + y * 2) % 5 == 0 and (x // 1 + y) % 2 == 0 then c:px(x, y, D.TAN[2]) end
  if (x * 2 + y) % 7 == 0 and y % 3 == 0 then c:px(x, y, D.TAN[5]) end
end)
-- waist pinch
for _, p in ipairs{ {27, 32}, {28, 33}, {36, 32}, {37, 31}, {28, 31}, {35, 33} } do c:px(p[1], p[2], D.TAN[2]) end
-- crack and nut at the upper end
local nut = D.ell(45, 20, 3, 2.5, 0.4)
c:fillMask(nut, D.CRM[3]) c:px(44, 19, D.CRM[6]) c:px(46, 21, D.CRM[1])
D.pts(c, { {41, 25}, {42, 24}, {43, 23}, {44, 22}, {45, 22}, {46, 21}, {47, 20} }, D.TAN[1])
D.pts(c, { {42, 26}, {43, 25}, {44, 24} }, D.TAN[2])
D.fin()
