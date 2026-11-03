-- ico-scroll first draft. parchment with two rolled ends, ink lines, wax seal. quirk: the seal ribbon tails and a curling corner
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-scroll")
D.lit(c, c:rect(15, 12, 49, 51), D.CRM, 5, { amb = 0.15 })
D.R(c, 15, 12, 15, 51, "#ecd4a8")
-- rolls
D.cyl(c, 11, 11, 53, 11, function(t) return 4.4 end, D.TAN)
D.cyl(c, 11, 52, 53, 52, function(t) return 4.4 end, D.TAN)
D.R(c, 12, 9, 14, 9, "#f8e2b4")
-- text
for i, y in ipairs{ 20, 26, 32 } do D.R(c, 21, y, 43 - (i % 2) * 6, y + 1, "#6f4033") end
D.pts(c, { {21, 38}, {22, 37}, {23, 38}, {22, 39} }, "#3a6aa6")
-- seal
D.polyline(c, { {40, 42}, {37, 51} }, "#a82c3c") D.polyline(c, { {41, 43}, {41, 52} }, "#d4403a")
D.polyline(c, { {44, 42}, {47, 50} }, "#a82c3c")
D.lit(c, D.ell(42, 41, 5, 5), D.RED, 3) D.R(c, 40, 39, 41, 39, "#ff9a78") D.R(c, 41, 41, 43, 43, "#a82c3c")
D.fin()
