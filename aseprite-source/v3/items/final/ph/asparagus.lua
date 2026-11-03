local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("asparagus")
-- asparagus: bundle of five slim spears with purple-budded scaly tips, tied with twine, cut ends pale. quirk: the tallest spear has already feathered into a tiny fern.
D.shadow(32, 58, 14, 2)
local spears = {{22,10,20,-0.05},{27,16,26,0},{32,18,32,0},{37,16,38,0.0},{42,12,44,0.05}}
local G = {"#2a5a2c","#3f7a38","#5a9a44","#7ab854","#a0d470","#cff09c"}
for i, s in ipairs(spears) do
  D.H.cyl(c, s[3], 52, s[1], s[2], function(t) return 2.5 - t * 0.2 end, G, {})
  -- tip scales
  for k = 0, 3 do D.px(s[1] - 1, s[2] + 1 + k * 2, "#7a5a98") D.px(s[1] + 1, s[2] + 2 + k * 2, "#5a3f78") end
  D.E(s[1], s[2] - 1, 1.8, 3, 0, {"#3a2a52","#5a3f78","#7a5a98","#8a9a58","#a8c070","#cce08c"}, 1)
  D.px(s[1] - 1, s[2], "#b89acc")
end
-- ferny spear
D.ln(22, 12, 18, 6, "#a0d470") D.ln(22, 12, 26, 6, "#7ab854") D.ln(21, 9, 17, 9, "#a0d470") D.ln(23, 9, 27, 9, "#7ab854") D.px(22, 5, "#cff09c")
-- pale cut ends
D.E(32, 54, 12, 3, 0, {"#a8a060","#c8c080","#e0dc9c","#f0ecb4","#f8f4cc","#fffce4"}, 1.5)
for _, s in ipairs(spears) do D.px(s[3], 53, "#8a8a50") end
-- twine tie
D.ln(18, 37, 46, 37, "#b88c5c") D.ln(18, 38, 46, 38, "#8f6a46") D.ln(18, 36, 46, 36, "#d9b37c")
D.ln(34, 38, 38, 44, "#b88c5c") D.ln(35, 38, 40, 42, "#8f6a46")
D.fin()
