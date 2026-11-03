local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("artichoke-fava-stew")
-- artichoke-fava-stew: terracotta bowl of golden broth with pale artichoke hearts, bright fava beans, a lemon wedge and herb flecks. quirk: one fava bean has hopped out and sits on the rim.
D.shadow(32, 56, 22, 3)
D.E(32, 42, 24, 12, 0, {"#5a2a1c","#8a4228","#b0603a","#cc7c48","#e49a5c","#f8b878"}, 5)
D.E(32, 37, 21, 8.5, 0, {"#6a3a14","#a8681e","#d09030","#ecb040","#f8cc5c","#ffe48a"}, 4)
-- artichoke hearts
for _, p in ipairs{{24,36,0.4},{36,38,-0.3},{30,34,0}} do
  D.E(p[1], p[2], 4.5, 3, p[3], {"#7a8a48","#98a85a","#b8c470","#d2dc8a","#e8eeaa","#f6f8cc"}, 2)
  D.px(p[1]-1, p[2], "#7a5a98")
end
-- fava beans
for _, p in ipairs{{20,40},{28,41},{40,35},{42,40},{33,41},{25,32}} do D.E(p[1], p[2], 2.6, 1.8, 0.3, D.LEAF2, 1.2) end
for _, p in ipairs{{30,38},{22,36},{38,42},{36,34}} do D.px(p[1], p[2], "#3f8a4e") end
-- herbs
for _, p in ipairs{{17,36},{26,37},{34,36},{44,38},{31,43}} do D.px(p[1], p[2], "#6ab455") end
-- lemon wedge
D.P({{44,30},{52,32},{50,36},{43,34}}, D.YEL, 1.5) D.ln(45, 32, 50, 34, "#fff2a8")
-- rim bean
D.E(11, 38, 2.6, 1.8, 0.5, D.LEAF2, 1.2) D.px(10, 37, "#fff4d6")
D.steam(28, 26, 8) D.steam(37, 24, 6)
D.px(14, 44, "#fff4d6") D.px(15, 44, "#fff4d6")
D.fin()
