local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("atlas-daisy-seed")
-- atlas-daisy-seed: flat winged tan achenes (a round seed in a papery rim) on a scrap of ferny daisy leaf; the seedling has finely cut leaves and a closed bud. quirk: the bud has a tiny crimson stripe like its flowers.
D.scrap(8, 54, 52, 48, 6, {"#2a5a44","#3f7a56","#5a9a64","#7ab874","#a0d48c","#cdf0b4"}, {norib=true})
for i = 0, 9 do local x = 12 + i * 4 D.ln(x, 49 + (i % 2), x + 1, 54, "#2a5a44") end
local W = {"#8a6a3a","#b08c52","#d0a868","#e6c488","#f4dcaa","#fff0cc"}
local function wing(x, y, a) D.E(x, y, 5.2, 4.2, a, W, 2.5) D.E(x + 0.4, y + 0.4, 2.2, 1.8, a, D.SEED, 1.2) D.px(x - 1, y - 1, "#fff4d6") end
wing(16, 50, 0.3) wing(28, 52, -0.2) wing(40, 49, 0.5)
D.ln(12, 48, 18, 46, "#8a6a3a") 
-- seedling
D.stem2(40, 45, 40, 26)
for _, d in ipairs{-1, 1} do
  local y0 = 36
  for k = 0, 3 do D.ln(40 + (d > 0 and 2 or 0), y0 - k * 4, 40 + d * (6 - k), y0 - k * 4 - 2, k % 2 == 0 and "#7ab874" or "#a0d48c") end
end
D.E(40, 22, 3, 4, 0, {"#6a1c3a","#a82c4c","#d4506c","#a0d48c","#cdf0b4","#e8f8d0"}, 1.8)
D.ln(40, 19, 40, 25, "#d4506c")
D.fin()
