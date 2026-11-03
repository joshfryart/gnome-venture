local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-chart")
local CR, INK = D.CR, D.INK
-- ico-chart: three rising bars (teal, gold, ember) on an L-shaped axis, with a bold up-arrow sweeping over them.
-- quirk: the shortest bar already has a tiny flag planted on top.
D.lit(c:rect(7, 8, 10, 56), D.GRY, 1.5) D.lit(c:rect(7, 53, 57, 56), D.GRY, 1.5)
D.lit(c:rect(14, 38, 24, 52), D.TEAL, 3)
D.lit(c:rect(28, 28, 38, 52), D.YEL, 3)
D.lit(c:rect(42, 16, 52, 52), D.RED, 3)
D.rect(15, 38, 23, 38, D.TEAL[6]) D.rect(29, 28, 37, 28, D.YEL[6]) D.rect(43, 16, 51, 16, D.RED[6])
D.rect(19, 28, 19, 37, D.GRY[1]) D.fill(c:poly{ {20, 28}, {26, 30}, {20, 33} }, "#e8493b") D.px(21, 29, CR)
D.poly(c, { {12, 28}, {26, 20}, {33, 22}, {47, 9} }, INK)
D.lit(c:line({ {12, 28}, {26, 20}, {33, 22}, {44, 12} }, 3), D.GREEN, 1.5)
D.lit(c:poly{ {43, 5}, {54, 4}, {53, 15} }, D.GREEN, 2)
D.fin()
