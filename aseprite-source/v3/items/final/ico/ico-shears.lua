-- ico-shears first draft. garden shears: crossed steel blades, red grips, brass pivot. quirk: a snipped leaf drifts away from the cut
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-shears")
local G = D.GRY
-- handles (cross)
D.tube(c, { {32, 32}, {22, 46}, {16, 56} }, 4, D.RED, 1.8)
D.tube(c, { {32, 32}, {42, 46}, {48, 56} }, 4, D.RED, 1.8)
D.lit(c, D.ell(14, 54, 4, 5), D.RED, 2) D.lit(c, D.ell(50, 54, 4, 5), D.RED, 2)
-- blades
D.lit(c, c:poly{ {29, 30}, {35, 30}, {22, 6}, {17, 7} }, G, 2.5)
D.lit(c, c:poly{ {29, 30}, {35, 30}, {47, 6}, {42, 5} }, G, 2.5)
D.polyline(c, { {20, 8}, {30, 29} }, "#eef0fa") D.polyline(c, { {44, 7}, {33, 29} }, "#cdd0e2")
D.lit(c, c:ellipse(32, 32, 3, 3), D.GOLD, 2) c:px(31, 31, "#fff0a0") c:px(32, 32, "#8f4a1f")
-- snipped leaf
D.leaf(c, 52, 22, 60, 34, 3, "moss", { 3 })
D.fin()
