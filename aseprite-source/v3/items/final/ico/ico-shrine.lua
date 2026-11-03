-- ico-shrine first draft. red torii gate on stone feet. quirk: a golden bell with a ribbon hangs between the posts
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-shrine")
c:groundShadow(32, 57, 22, 3)
for _, x in ipairs{ 14, 45 } do
  D.lit(c, c:rect(x, 16, x + 5, 54), "ember", 2.6)
  D.lit(c, c:rect(x - 2, 52, x + 7, 57), D.GRY, 1.6)
end
D.lit(c, c:rect(10, 28, 54, 33), "ember", 2.2)
-- top beam, upswept
D.lit(c, c:poly{ {4, 12}, {10, 18}, {54, 18}, {60, 12}, {60, 9}, {4, 9} }, D.RED, 3)
D.lit(c, c:poly{ {8, 6}, {56, 6}, {54, 10}, {10, 10} }, { "#150f22", "#251a3c", "#35295f", "#4a3a80", "#5e4b9a", "#7d69b8" }, 1.5)
-- bell
D.polyline(c, { {32, 33}, {32, 38} }, "#d4403a") D.polyline(c, { {33, 33}, {33, 38} }, "#a82c3c")
D.lit(c, c:poly{ {29, 44}, {36, 44}, {37, 47}, {28, 47} }:add(c:ellipse(32, 42, 4, 4)), D.GOLD, 2)
c:px(31, 40, "#fff0a0")
D.polyline(c, { {30, 48}, {29, 52} }, "#ee6a50") D.polyline(c, { {34, 48}, {35, 52} }, "#ee6a50")
D.fin()
