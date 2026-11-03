local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("artichoke-seed")
-- artichoke-seed: mottled grey-brown achenes each topped with a pale feathery pappus, on a deeply cut silvery artichoke leaf scrap; a seedling with notched leaves. quirk: one achene is tipped with a fluffy pappus the size of a dandelion clock.
D.scrap(8, 52, 54, 50, 7, {"#2a4a44","#3f6a5a","#5a8a72","#7aa88a","#a0c4a4","#cce0c0"})
for i = 0, 5 do D.px(14 + i * 7, 46 + (i % 2) * 8, "#2a4a44") D.px(15 + i * 7, 47 + (i % 2) * 8, "#2a4a44") end
local S = {"#2a2420","#4a423a","#6c6050","#8e806a","#b0a288","#d4c8aa"}
D.seed(16, 50, 4.2, 2.4, 0.5, S) D.seed(28, 53, 4.4, 2.4, -0.2, S) D.seed(42, 50, 4.2, 2.4, 0.2, S)
for _, p in ipairs{{15,49},{17,51},{27,52},{30,54},{41,49},{44,51}} do D.px(p[1], p[2], "#2a2420") end
-- pappus fluff on the right seed
for i = -3, 3 do D.ln(46, 49, 49 + i * 2, 42 - abs(i), "#fbf4e0") end
D.px(46, 48, "#d4c8aa")
-- seedling
D.stem2(28, 49, 28, 30)
D.cots(26, 33, 4, 1.8, D.LEAF2)
-- notched leaves
for _, d in ipairs{-1, 1} do
  local x = 29 + d * 5
  D.lf(x, 24, 4.5, 1.6, d * -0.5, D.LEAF) D.px(x + d, 22, "#cce0c0") D.px(x - d * 2, 26, "#cce0c0")
end
D.lf(28, 21, 1.8, 4, 0, D.LEAF2)
D.fin()
