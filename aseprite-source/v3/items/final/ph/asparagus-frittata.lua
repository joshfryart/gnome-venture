local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("asparagus-frittata")
-- asparagus-frittata: cast-iron skillet seen from above with a puffy golden frittata, green spears laid like spokes, one wedge cut out. quirk: the lifted wedge sits on a tiny spatula with a thread of steam.
D.shadow(28, 56, 24, 3)
-- handle
D.H.cyl(c, 50, 38, 62, 33, function() return 3 end, D.STEEL, {})
D.ln(50, 38, 61, 33, "#2f3350")
D.E(28, 38, 24, 16, 0, {"#14141e","#222230","#34344a","#4a4a62","#64647e","#8a8aa4"}, 5)
D.E(28, 36, 20, 12.5, 0, {"#b07a18","#d09a24","#eab62e","#f8d048","#ffe46e","#fff2a8"}, 5)
-- spokes
local G = {"#2a5a2c","#3f7a38","#5a9a44","#7ab854","#a0d470","#cff09c"}
for i = 0, 5 do local a = i * 1.05 + 0.3
  local x1, y1 = 28 + cos(a) * 17, 36 + sin(a) * 10
  D.H.cyl(c, 28 + cos(a) * 3, 36 + sin(a) * 2, x1, y1, function() return 1.5 end, G, {})
end
for _, p in ipairs{{18,32},{36,44},{40,32},{22,42},{30,30}} do D.px(p[1], p[2], "#d09a24") D.px(p[1]+1, p[2], "#b07a18") end
-- cut wedge: empty
D.P({{28,36},{44,30},{46,38}}, {"#14141e","#222230","#34344a","#4a4a62","#64647e","#8a8aa4"}, 1)
D.ln(28, 36, 44, 30, "#b07a18") D.ln(28, 36, 46, 38, "#b07a18")
-- spatula with wedge
D.P({{46,16},{58,14},{60,22},{48,24}}, D.STEEL, 1.5)
D.P({{47,12},{57,10},{59,17},{49,19}}, {"#b07a18","#d09a24","#eab62e","#f8d048","#ffe46e","#fff2a8"}, 1.5)
D.px(52, 14, "#5a9a44") D.px(53, 14, "#7ab854")
D.steam(50, 8, 4)
D.px(14, 30, "#fff4d6") D.px(15, 30, "#fff4d6")
D.fin()
