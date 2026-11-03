local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-chair")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-chair: ladder-back wooden chair seen from the front-left: tall back with three slats, flat seat, four chunky legs.
-- quirk: the front-right leg is short and propped up on a folded scrap of paper.
c:groundShadow(34, 59, 20, 2)
D.lit(c:rect(15, 5, 18, 35), D.WOODR, 1.8) D.lit(c:rect(41, 5, 44, 35), D.WOODR, 1.8)
for _, y in ipairs{ 8, 15, 22 } do D.lit(c:rect(18, y, 41, y + 3), D.WOODR, 1.6) end
D.lit(c:rect(13, 34, 47, 40), D.WOODR, 3)
D.rect(14, 34, 46, 34, D.WOODR[6])
D.lit(c:rect(14, 40, 18, 56), D.WOODR, 1.8) D.lit(c:rect(42, 40, 46, 53), D.WOODR, 1.8)
D.lit(c:rect(23, 40, 26, 50), D.WOODR, 1.5) D.lit(c:rect(37, 40, 40, 50), D.WOODR, 1.5)
D.fill(c:rect(41, 54, 49, 57), D.CR); D.rect(41, 57, 49, 57, "#c9a98a"); D.px(45, 55, "#c9a98a")
D.fin()
