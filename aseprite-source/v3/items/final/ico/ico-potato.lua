local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-potato: lumpy tan spud with dark eyes, soil specks and a freckled skin.
-- quirk: one eye has sprouted a little green shoot with two leaves.
local c = D.new("ico-potato")
c:groundShadow(32, 56, 17, 2)
local m = D.ell(31, 36, 19, 14, -0.2):add(D.ell(40, 31, 9, 9)):add(D.ell(20, 41, 9, 8))
D.lit(c, m, D.TAN, 10, { amb = 0.08 })
m:each(function(x, y)
  if X.hash(x, y, 7) > 0.93 then c:px(x, y, D.TAN[2]) elseif X.hash(x, y, 3) > 0.96 then c:px(x, y, D.TAN[5]) end
end)
for _, p in ipairs{ {22, 33}, {36, 40}, {44, 35}, {28, 45} } do
  D.rect(c, p[1], p[2], p[1] + 1, p[2] + 1, D.TAN[1]) c:px(p[1] + 2, p[2], D.TAN[2])
end
D.rect(c, 46, 44, 47, 44, "#6a4a30") D.rect(c, 15, 32, 15, 33, "#6a4a30")
D.ln(c, 37, 40, 37, 38, D.TAN[1])
D.ln(c, 44, 33, 46, 26, D.GRN[3]) D.ln(c, 45, 33, 47, 26, D.GRN[2])
D.leaf(c, 46, 27, 39, 20, 3, D.GRN, {})
D.leaf(c, 47, 27, 54, 21, 3, D.GRN, {})
D.fin()
