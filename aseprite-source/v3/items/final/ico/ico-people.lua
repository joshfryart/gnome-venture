local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-people: two gnome friends shoulder to shoulder, green and purple pointy hats, white beards.
-- quirk: the purple gnome's hat tip flops over, the green one sports a jaunty red feather.
local c = D.new("ico-people")
local function gnome(cx, hatRamp, beard)
  local hat = c:poly{ {cx - 11, 28}, {cx + 11, 28}, {cx + 4, 8}, {cx - 3, 6} }
  local face = c:ellipse(cx, 33, 9, 8)
  local bd = c:poly{ {cx - 9, 34}, {cx + 9, 34}, {cx + 2, 56}, {cx - 2, 56} }
  D.lit(c, face, D.SKIN, 5)
  D.lit(c, bd, D.CRM, 5, { amb = 0.15 })
  D.lit(c, hat, hatRamp, 5)
  for x = cx - 11, cx + 11 do c:px(x, 28, hatRamp[1]) end
  c:eyeSmall(cx - 5, 31) c:eyeSmall(cx + 3, 31)
  c:fillMask(c:ellipse(cx - 0.5, 36, 2, 2), D.SKIN[3]) c:px(cx - 1, 35, D.SKIN[6])
  c:cheek(cx - 8, 36) c:cheek(cx + 6, 36)
  return hat
end
gnome(20, D.PURP)
-- floppy tip on the purple hat
local tip = D.ell(11, 10, 4, 3, 0.5)
D.lit(c, tip, D.PURP, 2)
gnome(44, D.GRN)
D.leaf(c, 46, 9, 56, 3, 3, D.RED, {})
D.fin()
