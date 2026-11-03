local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local c = D.new("ant-chitin")
-- ant-chitin: shed armour of a black ant: three overlapping banded abdomen plates, a jointed leg and a hooked mandible. quirk: a sugar crystal is stuck to the biggest plate.
local C = D.CHIT
D.shadow(32, 54, 20, 3)
-- jointed leg behind
D.ln(44, 28, 54, 18, C[4]) D.ln(45, 28, 55, 18, C[3]) D.ln(54, 18, 57, 24, C[4]) D.ln(55, 18, 58, 24, C[3])
D.E(44, 29, 2.2, 2.2, 0, C, 2) D.E(55, 20, 1.6, 1.6, 0, C, 1.5)
-- plates, rear to front
D.E(20, 36, 11, 8, -0.5, C, 4) D.E(29, 42, 11, 7.5, -0.3, C, 4) D.E(39, 44, 10, 7, 0, C, 4)
-- band seams
for _, s in ipairs{{26,31,22,43},{35,38,32,49}} do D.ln(s[1], s[2], s[3], s[4], C[1]) end
-- highlights on rim
D.ln(14, 31, 20, 28, C[6]) D.ln(24, 38, 31, 36, C[6]) D.ln(34, 40, 41, 39, C[6])
-- mandible hook
D.P({{9,26},{6,22},{6,17},{9,20},{11,25}}, C, 1.5)
D.px(7, 18, "#fff4d6")
-- sugar crystal
D.P({{26,35},{30,33},{33,36},{32,39},{28,40}}, {"#b8a8c0","#d8cce0","#f0e8f4","#fbf4fc","#fffaf4","#ffffff"} and {"#a898b8","#c8bcd8","#e0d8ec","#f0eaf6","#fbf6fc","#fff4d6"}, 1.5)
D.px(28, 35, "#ffffff" and "#fff4d6")
D.fin()
