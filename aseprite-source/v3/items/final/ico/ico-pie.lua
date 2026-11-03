local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-pie: golden pie in a tin, fat crimped crust rim and a woven lattice over red filling.
-- quirk: a curl of steam and one filling bubble seeping through the lattice.
local c = D.new("ico-pie")
c:groundShadow(32, 53, 26, 3)
local tin = c:ellipse(32, 41, 25, 12):add(c:rect(7, 41, 57, 46)):clip(c:rect(0, 0, 63, 49))
D.lit(c, c:ellipse(32, 42, 25, 12), D.BRN, 6)
local side = c:ellipse(32, 44, 25, 11):add(c:rect(7, 38, 57, 44)):clip(c:rect(0, 40, 63, 50))
D.lit(c, side, D.TAN, 6, { amb = 0.18 })
local top = c:ellipse(32, 37, 25, 12)
D.lit(c, top, D.TAN, 9, { amb = 0.1 })
local fill = c:ellipse(32, 37, 19, 8)
c:fillMask(fill, D.RED[2])
fill:each(function(x, y) if (x + y) % 5 == 0 then c:px(x, y, D.RED[3]) end end)
for i = -2, 2 do
  local o = i * 7
  D.ln(c, 14 + o + 7, 29, 28 + o + 7, 45, D.TAN[4], fill)
  D.ln(c, 50 + o - 7, 29, 36 + o - 7, 45, D.TAN[3], fill)
end
-- crimp
for a = 0, 31 do local t = a / 32 * 2 * pi
  local x, y = floor(32 + cos(t) * 24 + .5), floor(37 + sin(t) * 11 + .5)
  if a % 2 == 0 then c:px(x, y, D.TAN[2]) else c:px(x, y, D.TAN[6]) end end
c:fillMask(c:ellipse(36, 36, 2, 1.5), D.RED[4]) c:px(35, 35, D.RED[6])
-- steam
D.pts(c, { {30, 22}, {29, 21}, {29, 20}, {30, 19}, {31, 18}, {31, 17}, {30, 16}, {30, 15}, {31, 14} }, D.CRM[3])
D.pts(c, { {31, 22}, {30, 21}, {30, 20}, {31, 19}, {32, 18}, {32, 17}, {31, 16}, {31, 15}, {32, 14} }, D.CRM[5])
D.fin()
