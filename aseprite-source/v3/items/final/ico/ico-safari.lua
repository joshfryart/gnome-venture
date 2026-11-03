-- ico-safari first draft. grey elephant facing left in an explorer's pith helmet. quirk: the pith helmet
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-safari")
c:groundShadow(32, 56, 22, 3)
local G = D.GRY
-- far legs
D.lit(c, c:rect(21, 42, 26, 55), G, 2) D.lit(c, c:rect(42, 42, 47, 55), G, 2)
-- body
D.lit(c, D.ell(34, 36, 18, 12), G, 6)
-- near legs
D.lit(c, c:rrect(17, 42, 24, 55, 1), G, 2.5) D.lit(c, c:rrect(38, 42, 45, 55, 1), G, 2.5)
D.R(c, 17, 53, 24, 55, "#5a5e7c") D.R(c, 38, 53, 45, 55, "#5a5e7c")
-- tail
D.polyline(c, { {52, 32}, {56, 38}, {55, 45} }, "#7e829e") D.polyline(c, { {53, 32}, {57, 38}, {56, 45} }, "#5a5e7c")
D.R(c, 54, 45, 56, 47, "#3a3d56")
-- head
D.lit(c, c:ellipse(17, 29, 9, 9), G, 4)
-- trunk
D.tube(c, { {11, 33}, {8, 40}, {9, 47}, {13, 50} }, 5, G, 2)
-- tusk
D.tube(c, { {13, 38}, {15, 44}, {19, 47} }, 3, D.CRM, 1)
-- ear
D.lit(c, D.ell(25, 31, 5, 8, 0.1), { "#6a4a6a", "#a06a86", "#d08aa6", "#e8a4bc", "#f4c0d0", "#ffd8e2" }, 3)
D.seam(c, D.ell(25, 31, 5, 8, 0.1), c:rect(0, 0, 0, 0), "#5a5e7c")
-- eye
c:eyeSmall(14, 26)
-- pith helmet
D.lit(c, D.ell(17, 22, 8, 6), D.TAN, 3)
D.lit(c, D.ell(17, 25, 12, 2.4), D.TAN, 1.4)
D.R(c, 11, 22, 23, 23, "#8a4a26")
D.R(c, 12, 22, 14, 23, "#d4403a")
D.fin()
