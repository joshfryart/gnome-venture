local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-stamp-cart: wooden stamp-mill ore cart on two iron wheels, heaped with green ore, push handle at the back.
-- quirk: a tiny red pennant flies from the handle and one ore chunk sparkles.
local c = D.new("ico-stamp-cart")
c:groundShadow(30, 59, 22, 2)
D.cyl(c, 50, 30, 58, 12, function() return 1.8 end, D.BRN, { amb = 0.08 })
c:fillMask(c:poly{ {58,9},{58,17},{51,13} }, D.RED[4]) c:px(57, 11, D.RED[6])
for i, o in ipairs{ {14,26,6},{27,22,7},{41,25,6} } do D.lit(c, D.ell(o[1], o[2], o[3], o[3] - 1), D.GRN, 4) end
c:px(24, 19, D.GRN[6]) c:px(25, 19, D.GRN[6])
local body = c:poly{ {6,28},{54,28},{49,48},{11,48} }
D.lit(c, body, D.BRN, 10, { amb = 0.1 })
for x = 16, 44, 12 do D.ln(c, x, 30, x - 1, 47, D.BRN[2]) end
D.ln(c, 8, 33, 52, 33, D.BRN[6])
D.rect(c, 6, 28, 54, 31, D.GRY[3]) D.rect(c, 6, 28, 54, 28, D.GRY[5]) D.rect(c, 11, 46, 49, 48, D.GRY[2])
c:px(10, 37, D.GRY[6]) c:px(48, 37, D.GRY[2]) c:px(10, 42, D.GRY[6])
for _, x in ipairs{ 18, 42 } do
  D.disc(c, x, 53, 5, D.GRY) c:fillMask(c:ellipse(x, 53, 1, 1), D.INK)
end
c:sparkle(32, 14)
D.fin()
