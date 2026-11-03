-- ico-shield first draft. heater shield, blue field with steel rim and gold boss. quirk: a stray arrow stuck in the top corner
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-shield")
local sh = c:poly{ {10, 12}, {54, 12}, {54, 30}, {48, 44}, {32, 58}, {16, 44}, {10, 30} }
D.lit(c, sh, D.GRY, 5)
local inner = c:poly{ {14, 16}, {50, 16}, {50, 30}, {45, 42}, {32, 54}, {19, 42}, {14, 30} }
D.lit(c, inner, D.BLU, 6)
D.R(c, 29, 16, 35, 54, "#e8a42e")
D.lit(c, c:rect(29, 16, 35, 52):clip(inner), D.GOLD, 1.5)
D.lit(c, c:ellipse(32, 31, 6, 6), D.GRY, 3) D.lit(c, c:ellipse(32, 31, 3, 3), D.GOLD, 1.5)
c:px(30, 29, "#fff4d6")
-- arrow
D.polyline(c, { {58, 4}, {44, 20} }, "#c98a54") D.polyline(c, { {59, 5}, {45, 21} }, "#864c33")
D.lit(c, c:poly{ {54, 2}, {62, 2}, {62, 10}, {58, 6} }, D.RED, 1)
D.polyline(c, { {50, 2}, {57, 9} }, "#ee6a50")
D.fin()
