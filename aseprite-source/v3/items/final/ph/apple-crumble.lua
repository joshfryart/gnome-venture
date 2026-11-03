local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local c = D.new("apple-crumble")
-- apple-crumble: oval ceramic baking dish with a lumpy golden crumble crust and bubbling apple at the edge. quirk: a spoon stands in it with a scoop of crumble still on it.
D.shadow(30, 55, 22, 3)
D.E(30, 44, 22, 11, 0, {"#1c3a6a","#2a4a7a","#3a6aa6","#4a8acc","#78b4ea","#b6dcf6"}, 4)
D.E(30, 42, 19, 8.5, 0, {"#6a2c18","#8c3c1e","#b0562a","#d27a38","#eba04c","#fbc872"}, 4)
-- apple filling at left edge
D.E(15, 42, 3, 4, 0, D.ORG, 1.5) D.E(14, 38, 2.4, 2.6, 0, D.ORG, 1.5)
-- crumble lumps
local pts = {{22,38},{28,36},{35,38},{41,40},{20,44},{27,43},{34,45},{41,46},{25,48},{32,49},{37,41},{30,41},{18,46}}
for i, p in ipairs(pts) do D.E(p[1], p[2], 2.6, 2, 0.3 * (i % 3 - 1), {"#8c3c1e","#b0562a","#d27a38","#eba04c","#fbc872","#ffe8a0"}, 1.5) end
-- spoon
D.ln(46, 20, 40, 38, "#9ea2bf") D.ln(47, 20, 41, 38, "#74789a")
D.E(48, 17, 3.2, 4.2, 0.3, D.STEEL, 2)
D.E(48, 15, 2, 2, 0, {"#b0562a","#d27a38","#eba04c","#fbc872","#ffe8a0","#fff2b8"}, 1)
D.steam(24, 30, 8) D.steam(33, 28, 6)
D.px(20, 42, "#fff4d6")
D.fin()
