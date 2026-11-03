local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-plate-cutlery: round cream plate between a fork and a knife, laid for a meal.
-- quirk: a single red cherry sits on the plate with its stem curling over the rim.
local c = D.new("ico-plate-cutlery")
c:groundShadow(32, 53, 25, 3)
local plate = c:ellipse(32, 32, 17, 17)
D.lit(c, plate, D.CRM, 10, { amb = 0.1 })
local inner = c:ellipse(32, 32, 11, 11)
inner:each(function(x, y)
  local d = sqrt((x - 32) ^ 2 + (y - 32) ^ 2)
  if d > 10 and d <= 11 then c:px(x, y, D.CRM[2]) end
end)
-- fork
local fork = c:rect(6, 29, 9, 51):add(c:rect(4, 12, 11, 28))
fork:cut(c:rect(7, 8, 8, 24))
D.lit(c, fork:copy():clip(c:rect(0, 0, 12, 63)), D.GRY, 3, { amb = 0.1 })
-- knife
local kn = c:rect(55, 33, 58, 52):add(c:poly{ {54, 33}, {58, 33}, {58, 10}, {55, 11}, {53, 20} })
D.lit(c, kn, D.GRY, 3, { amb = 0.1 })
D.rect(c, 55, 14, 55, 30, D.GRY[6])
D.rect(c, 55, 33, 58, 33, D.GRY[2])
D.rect(c, 55, 38, 58, 52, D.BRN[4]) D.rect(c, 55, 38, 55, 52, D.BRN[6]) D.rect(c, 58, 38, 58, 52, D.BRN[2])
-- cherry
local ch = c:ellipse(30, 33, 5, 5)
D.lit(c, ch, D.RED, 4) c:px(28, 31, CREAM) c:px(29, 31, CREAM)
D.ln(c, 31, 28, 35, 20, D.GRN[3]) D.ln(c, 32, 28, 36, 20, D.GRN[2])
D.fin()
