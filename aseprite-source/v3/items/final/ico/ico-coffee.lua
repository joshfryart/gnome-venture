local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-coffee")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-coffee: stout cream mug with a loop handle on a saucer, dark brew with a cream heart, two curly steam wisps.
-- quirk: the latte-art heart, and a spoon resting on the saucer rim.
c:groundShadow(32, 58, 24, 2)
D.lit(ell(32, 54, 22, 4, 0), D.GRY, 3)
D.lit(c:line({ {43, 34}, {52, 34}, {53, 44}, {45, 47} }, 4), D.CREAM, 2)
D.fill(c:ellipse(49, 41, 2, 3), INK)
local body = c:rrect(13, 28, 46, 52, 6):clip(c:rect(0, 28, 63, 52))
D.fill(ell(30, 28, 17, 5, 0), D.CREAM[2])
body:add(ell(30, 28, 17, 5, 0))
D.lit(body, D.CREAM, 9, { amb = 0.1 })
D.fill(ell(30, 28, 15, 4, 0), "#2a1620"); D.fill(ell(30, 28, 14, 3, 0), "#5a3020")
D.fill(c:rect(26, 27, 29, 27), D.CR) D.fill(c:rect(31, 27, 34, 27), D.CR) D.fill(c:rect(27, 28, 33, 28), D.CR) D.rect(29, 29, 31, 29, D.CR)
D.px(17, 36, "#fffbe8") D.px(17, 37, "#fffbe8")
D.poly(c, { {58, 50}, {52, 55} }, D.GRY[5]) D.fill(c:ellipse(59, 49, 2, 2), D.GRY[4])
for _, x in ipairs{ 25, 33 } do
  D.poly(c, { {x, 22}, {x - 2, 19}, {x + 1, 15}, {x - 1, 11}, {x, 8} }, "#e6f6ff")
  D.poly(c, { {x + 1, 22}, {x - 1, 19}, {x + 2, 15}, {x, 11} }, "#b9e2f5")
end
D.fin()
