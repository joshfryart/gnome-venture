local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("bok-choy")
-- bok-choy: a slim bunch of spoon-shaped dark leaves on fat pale-jade stalks with a trimmed white root base. quirk: a caterpillar sits on one leaf.
D.stem2(22, 28, 22, 29)
for i, p in ipairs{{20,4,-0.3},{32,2,0},{44,5,0.3}} do end
D.E(19, 16, 6, 11, -0.2, D.LEAF, 3) D.E(45, 16, 6, 11, 0.2, D.LEAF, 3) D.E(32, 14, 7, 13, 0, D.LEAF2, 3.5)
D.ln(32, 6, 32, 26, "#e6f0c0") D.ln(19, 8, 21, 26, "#bfe688") D.ln(45, 8, 43, 26, "#7ab455")
D.px(29, 9, "#fff4d6") D.px(30, 9, "#fff4d6")
D.P({{22,26},{26,24},{26,50},{22,50}}, D.CRM, 2) D.P({{30,24},{34,24},{34,52},{30,52}}, D.CRM, 2) D.P({{38,24},{42,24},{42,50},{38,50}}, D.CRM, 2)
D.ln(23, 28, 23, 48, "#fffbe8") D.ln(31, 28, 31, 50, "#fffbe8")
D.P({{22,50},{42,50},{38,58},{26,58}}, D.TAN, 2) D.ln(27, 56, 37, 56, "#8f6a46") D.ln(26, 52, 30, 56, "#b88c5c")
D.E(14, 20, 1.6, 1.2, 0, D.PINK, 1) D.E(17, 21, 1.4, 1.2, 0, D.PINK, 1) D.E(20, 20, 1.4, 1.2, 0, D.PINK, 1)
D.px(13, 18, "#fff4d6")
D.fin()
