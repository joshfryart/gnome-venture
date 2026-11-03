local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blue-mussels")
-- blue-mussels: two slim blue-black mussels leaning together, ridged growth lines, pearly nacre inside the open one, beard threads. quirk: a tiny pearl rests in the open shell.
D.shadow(32, 58, 18, 2)
D.P({{10,50},{16,28},{30,14},{36,22},{30,44},{20,54}}, D.MUSS, 3)
for i = 0, 4 do D.ln(14 + i * 3, 46 - i * 5, 22 + i * 2, 50 - i * 6 + 8, "#1a2252") end
D.px(20, 24, "#a4b8e8") D.px(21, 24, "#a4b8e8") D.px(22, 22, "#a4b8e8")
D.P({{30,54},{36,34},{48,18},{54,28},{50,46},{40,56}}, D.MUSS, 3)
D.P({{32,50},{37,36},{46,24},{50,30},{47,44},{40,52}}, D.GLASS, 2) D.P({{38,46},{42,34},{48,30},{46,42}}, D.CRM, 2)
D.ln(34, 52, 40, 54, "#2a3a7c") D.ln(31, 54, 34, 54, "#5a4638")
D.ln(30, 50, 28, 57, "#2e2820") D.ln(32, 52, 31, 58, "#463c30") D.ln(34, 53, 35, 58, "#2e2820")
D.E(43, 38, 2, 2, 0, D.CRM, 1) D.px(42, 37, "#fffbe8")
D.fin()
