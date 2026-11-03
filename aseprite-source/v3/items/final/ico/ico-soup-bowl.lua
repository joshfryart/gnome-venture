-- ico-soup-bowl first draft. teal bowl of orange soup, steam curls, spoon. quirk: one noodle drapes over the rim
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-soup-bowl")
c:groundShadow(32, 57, 21, 3)
-- steam
for _, x in ipairs{ 24, 34 } do
  D.polyline(c, { {x, 22}, {x + 3, 18}, {x, 14}, {x + 3, 10} }, "#fff4d6") D.polyline(c, { {x + 1, 22}, {x + 4, 18}, {x + 1, 14}, {x + 4, 10} }, "#e6cfa8")
end
-- spoon
D.polyline(c, { {44, 30}, {55, 14} }, "#cdd0e2") D.polyline(c, { {45, 30}, {56, 14} }, "#7e829e")
D.lit(c, D.ell(56, 12, 3, 4, 0.5), D.GRY, 1.5)
-- bowl body
local body = D.ell(32, 33, 23, 21):clip(c:rect(0, 33, 63, 63))
D.lit(c, body, D.TEAL, 7, { amb = 0.12 })
D.R(c, 11, 44, 53, 45, "#fff4d6") D.R(c, 14, 48, 50, 48, "#fff4d6")
-- soup
D.lit(c, D.ell(32, 33, 23, 7), D.ORG, 3)
D.lit(c, D.ell(32, 33, 23, 7):shrink(0), D.ORG, 3)
D.lit(c, D.ell(32, 33, 20, 5), D.ORG, 3)
D.R(c, 9, 33, 55, 34, "#2a5a6c")
-- floaters
D.lit(c, c:ellipse(24, 33, 2, 2), "moss", 1) D.lit(c, c:ellipse(38, 32, 2, 2), D.YEL, 1) D.lit(c, c:ellipse(31, 35, 2, 1), "moss", 1)
D.pts(c, { {42, 34}, {43, 34} }, "#ffd080")
-- noodle over the rim
D.polyline(c, { {16, 34}, {13, 38}, {14, 44}, {13, 50} }, "#f8e8c0") D.polyline(c, { {17, 34}, {14, 38}, {15, 44}, {14, 50} }, "#d4b48a")
D.fin()
