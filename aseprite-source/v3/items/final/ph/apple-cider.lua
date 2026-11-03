local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local c = D.new("apple-cider")
-- apple-cider: tall glass mug with a loop handle, cloudy amber cider, a cream foam cap and a cinnamon stick. quirk: a thin apple slice is wedged on the rim like a lemon.
D.shadow(28, 57, 15, 2.5)
-- handle
D.ln(42, 24, 52, 26, "#b2dce4") D.ln(52, 26, 53, 42, "#86b8c8") D.ln(53, 42, 42, 46, "#b2dce4") D.ln(43, 27, 50, 28, "#5a8aa0") D.ln(51, 29, 51, 40, "#5a8aa0") D.ln(50, 41, 43, 44, "#5a8aa0")
local mug = c:rrect(12, 16, 42, 55, 4)
D.H.vcyl(c, mug, D.GLASS, 10, 44, {})
local liq = c:rrect(14, 24, 40, 53, 3)
D.H.vcyl(c, liq, D.ORG, 12, 42, {})
for _, p in ipairs{{20,40},{30,32},{25,48},{34,44}} do D.px(p[1], p[2], "#ffe08a") end
-- foam
D.E(27, 24, 14, 3.5, 0, D.CRM, 2)
for _, p in ipairs{{17,21},{22,20},{29,20},{35,21}} do D.E(p[1], p[2], 2.2, 2, 0, D.CRM, 1.5) end
-- cinnamon
D.H.cyl(c, 24, 22, 38, 5, function() return 1.8 end, {"#3a1a14","#5c2a1c","#7e3c24","#a05430","#c07442","#e0a066"}, {})
D.ln(25, 22, 36, 8, "#3a1a14")
-- apple slice on rim
D.P({{36,14},{44,13},{44,19},{37,20}}, {"#d8b87c","#ecd09c","#f8e6b8","#fff0c8","#fff8dc","#fffbe8"}, 1.5)
D.ln(37, 14, 43, 14, "#ee6a50")
D.steam(18, 12, 7)
D.px(16, 34, "#fff4d6") D.px(16, 35, "#fff4d6") D.px(16, 36, "#fff4d6")
D.fin()
