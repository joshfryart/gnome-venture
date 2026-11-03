local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fish: blue fish swimming left, cream belly, orange fins and tail.
-- quirk: it blows two bubbles from its mouth.
local c = D.new("ico-fish")
local tail = c:poly{ {40,32},{57,18},{52,32},{57,46} }
D.lit(tail, D.ORG, 5, { amb = 0.08 })
local fin1 = c:poly{ {18,23},{26,11},{37,22} }
local fin2 = c:poly{ {22,41},{26,51},{35,42} }
D.lit(fin1, D.ORG, 5) D.lit(fin2, D.ORG, 5)
local body = c:ellipse(27, 32, 18, 12)
D.lit(body, D.BLUE, 10, { amb = 0.05 })
D.lit(D.isect(c:ellipse(27, 41, 17, 7), body), D.CREAM, 5)
D.poly(c, { {20,26},{22,32},{20,38} }, D.BLUE[1])
for _, p in ipairs{ {28,28},{33,31},{38,29},{30,34},{36,35} } do c:px(p[1], p[2], D.BLUE[5]) c:px(p[1]+1, p[2], D.BLUE[3]) end
c:eyeSmall(13, 28)
c:px(10, 34, INK) c:px(11, 35, INK)
for _, b in ipairs{ {8,22,3},{12,13,2} } do D.fill(D.ring(b[1], b[2], b[3] + 1, b[3] - 1), "#b6dcf6") c:px(b[1] - 1, b[2] - 1, CR) end
D.fin()
