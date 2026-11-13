local D = debug.getinfo(1, "S").source:match("@(.*/)")
local L = dofile(D .. "lib47.lua"); local T = dofile(D .. "tiles.lua")
for _, s in ipairs({ "strip", "hand" }) do for _, t in ipairs(L.ORDER) do T.build(L.CFG[s], t) end end
