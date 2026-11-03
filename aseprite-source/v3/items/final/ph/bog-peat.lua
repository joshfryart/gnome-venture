local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("bog-peat")
-- bog-peat: a neat dark-brown cut brick of peat with fibrous layers, root hair strands, a grass tuft on top. quirk: a sphagnum moss tuft grows green on one corner.
D.shadow(32, 55, 19, 3)
D.P({{12,26},{44,22},{54,28},{50,48},{18,52},{10,44}}, D.BOG, 3)
D.P({{12,26},{44,22},{54,28},{22,32}}, D.BOG, 2)
D.ln(12, 26, 44, 22, "#b09a76") D.ln(44, 22, 54, 28, "#8a7458")
for _, y in ipairs{36, 42, 47} do D.ln(14, y, 48, y - 3, "#2e2820") D.ln(16, y + 1, 46, y - 2, "#665644") end
for _, p in ipairs{{20,40},{30,38},{40,44},{26,46},{44,34}} do D.ln(p[1], p[2], p[1] + 4, p[2] - 1, "#b09a76") end
D.px(46, 22, "#6ab455")
D.E(16, 27, 5, 3, 0, D.LEAF, 2) D.px(14, 26, "#bfe688") D.px(18, 25, "#9dd06c") D.px(16, 23, "#6ab455") D.px(17, 22, "#9dd06c")
D.ln(34, 22, 33, 15, "#86b86c") D.ln(36, 22, 38, 14, "#5a9a50") D.ln(38, 23, 42, 16, "#86b86c")
D.fin()
