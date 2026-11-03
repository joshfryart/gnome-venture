-- ico-rope first draft. coiled hemp rope with twist. quirk: the loose end is tied in a tiny knot and frays
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-rope")
local ring = D.ell(29, 31, 20, 17):cut(D.ell(29, 31, 8, 6))
D.lit(c, ring, D.TAN, 4.5)
ring:each(function(x, y) if ((x + y) // 4) % 2 == 0 then D.shift(c, x, y, D.TAN, -1) end end)
local m = D.ell(29, 31, 20, 17):cut(D.ell(29, 31, 14, 11))
-- loop seam
D.polyline(c, { {29, 14}, {29, 20} }, "#5a3a28")
D.polyline(c, { {10, 31}, {17, 31} }, "#5a3a28")
-- tail
local tail = D.swept(c, D.bez({ {46, 40}, {54, 44}, {48, 54}, {56, 56} }, 24), function(t) return 2.2 - t * .4 end)
D.lit(c, tail, D.TAN, 1.8)
tail:each(function(x, y) if ((x + y) // 3) % 2 == 0 then D.shift(c, x, y, D.TAN, -1) end end)
-- knot + fray
D.lit(c, c:ellipse(53, 46, 3, 3), D.TAN, 2)
D.pts(c, { {58, 57}, {59, 55}, {57, 59}, {55, 59} }, "#e8c488")
D.R(c, 20, 20, 22, 21, "#f8e2b4")
D.fin()
