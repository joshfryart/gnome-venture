-- ico-ruin first draft. two fluted columns, one snapped, on a mossy slab. quirk: a tiny sapling grows from the broken column
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-ruin")
c:groundShadow(32, 55, 24, 3)
D.lit(c, c:rect(7, 49, 57, 56), "stone", 2.5)
local c1 = c:rect(13, 14, 25, 49)
D.lit(c, c:rect(10, 11, 28, 16), "stone", 1.5)
D.lit(c, c1, "stone", 3.5)
for x = 16, 22, 3 do D.polyline(c, { {x, 18}, {x, 48} }, "#74758c") end
-- broken column
local b = D.mk(36, 30, 50, 50, function(x, y) return y >= 33 + ((x * 5) % 6) end)
D.lit(c, b, "stone", 3.5)
for x = 39, 47, 4 do D.polyline(c, { {x, 40}, {x, 48} }, "#74758c") end
D.lit(c, c:poly{ {29, 44}, {35, 42}, {36, 49}, {29, 49} }, "stone", 1.6)
-- moss
D.lit(c, c:poly{ {7, 49}, {16, 49}, {14, 52}, {9, 52} }, "moss", 1.2)
D.lit(c, c:poly{ {44, 33}, {50, 36}, {47, 38}, {43, 36} }, "moss", 1.2)
-- sapling
D.polyline(c, { {43, 34}, {43, 26} }, "#3f9150")
D.polyline(c, { {44, 34}, {44, 26} }, "#7cc35a")
D.lit(c, D.ell(39, 25, 4, 2.2, -0.5), "moss", 1.5) D.lit(c, D.ell(48, 24, 4, 2.2, 0.5), "moss", 1.5)
D.fin()
