-- ico-mouse first draft (Sonnet). quirk: it carries a cheese wedge that is bigger than its head
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-mouse")
local GRY = { "#5a5c78", "#74758c", "#9a9ab0", "#b8b8c8", "#d4d3de", "#ecebf2" }
c:groundShadow(30, 57, 22, 2)
-- tail
D.fill(c:line({ {46, 48}, {54, 50}, {58, 44}, {56, 36} }, 2), "#f5809f")
-- body
D.lit(D.ell(36, 42, 15, 11), GRY, 8)
-- feet
D.lit(D.ell(30, 54, 4, 2), "petal", 2, { nospec = true }) D.lit(D.ell(44, 54, 4, 2), "petal", 2)
-- head w/ snout
local head = D.ell(21, 37, 10, 9):add(c:poly{ {14, 32}, {6, 41}, {18, 46} })
D.lit(head, GRY, 6)
-- ear
D.lit(D.ell(24, 26, 7, 7), GRY, 3) D.fill(D.ell(24, 27, 4, 4), "#f5809f") D.fill(c:rect(22, 25, 23, 26), "#ffc4d8")
c:eyeSmall(19, 33)
D.fill(c:rect(5, 40, 8, 43), "#f5809f") D.fill(c:rect(5, 40, 6, 40), CR) 
D.fill(c:rect(8, 44, 10, 45), CR)
-- whiskers
D.ln(6, 38, 1, 35, "#74758c") D.ln(6, 44, 1, 47, "#74758c")
-- cheese in front
local ch = c:poly{ {26, 56}, {52, 56}, {52, 34}, {40, 38} }
ch:shrink(0)
D.lit(ch, D.ORG, 6)
D.fill(c:rect(26, 56, 52, 56), D.ORG[2])
D.fill(D.ell(44, 46, 3, 3), D.ORG[2]) D.fill(D.ell(36, 51, 2, 2), D.ORG[2]) D.fill(D.ell(48, 38, 1, 1), D.ORG[2])
c:px(43, 45, D.ORG[1]) c:px(35, 50, D.ORG[1])
D.fill(c:rect(28, 54, 29, 55), GRY[5])
D.fin()
