local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("bog-iron")
-- bog-iron: a lumpy rust-orange knobbly nodule of bog ore with rusty crust, dark holes, orange iron stain pooling underneath. quirk: a bubble of swamp water in a hollow.
D.shadow(32, 56, 17, 3)
D.E(32, 40, 18, 13, 0, D.RUST, 4)
D.E(20, 38, 8, 8, 0, D.RUST, 3) D.E(44, 36, 8, 8, 0, D.RUST, 3) D.E(30, 28, 9, 7, 0, D.RUST, 3) D.E(40, 46, 7, 6, 0, D.RUST, 3)
for _, p in ipairs{{24,44},{36,34},{28,48},{44,42},{18,40}} do D.E(p[1], p[2], 2, 1.4, 0, D.BOG, 1) D.px(p[1] - 1, p[2] - 1, "#b04a28") end
for _, p in ipairs{{26,26},{34,30},{22,34},{46,38},{32,42},{38,48}} do D.px(p[1], p[2], "#ee9c58") D.px(p[1] + 1, p[2], "#d27038") end
D.E(40, 40, 3, 2.4, 0, D.SEA, 1.5) D.px(39, 39, "#fcfffa")
D.ln(18, 52, 42, 52, "#d27038") D.ln(22, 53, 38, 53, "#823220")
D.fin()
