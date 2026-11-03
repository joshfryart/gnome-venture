local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blue-flag-iris-seed")
-- blue-flag-iris-seed: flat D-shaped amber seeds stacked in two rows on an iris sword-leaf scrap; sprout is a tall flat sword blade with a fan base. quirk: one seed lies on its edge like a dropped coin.
D.scrap(4, 56, 58, 52, 6, D.LEAF)
local S = {"#4a2808","#7a4812","#a8681c","#d08c2c","#eab040","#ffd878"}
for i = 0, 3 do D.seed(13 + i * 8, 49, 3.4, 4, 0.1, S) D.ln(13 + i * 8, 47, 13 + i * 8, 51, S[2]) end
D.E(50, 51, 1.6, 4, 0, S, 1) 
D.stem2(30, 44, 30, 40)
D.P({{28,40},{27,24},{29,10},{32,24},{33,40}}, D.LEAF2, 2)
D.P({{34,40},{38,28},{43,22},{41,32},{37,41}}, D.LEAF, 2)
D.ln(30, 12, 30, 38, "#bfe688")
D.fin()
