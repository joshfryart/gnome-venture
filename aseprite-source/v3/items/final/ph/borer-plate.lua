local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("borer-plate")
-- borer-plate: a slim curved chitin plate from a bark borer beetle, ridged stripes, glossy brown-black shell edge, notched rim. quirk: a tiny boring hole with a sawdust pile.
D.shadow(32, 57, 16, 2)
D.P({{10,40},{14,22},{30,12},{50,16},{54,36},{44,52},{26,54},{14,50}}, D.CHIT, 4)
for i = 0, 4 do D.ln(14 + i * 7, 46 - i * 2, 20 + i * 6, 16 + i * 1, i % 2 == 0 and "#251a26" or "#b0784c") end
D.ln(16, 24, 30, 14, "#e6b878") D.ln(18, 28, 22, 22, "#e6b878")
D.px(20, 20, "#fff4d6") D.px(21, 20, "#fff4d6")
for k = 0, 3 do D.px(12 + k * 2, 46 + k % 2, "#120c16") end
D.E(40, 36, 2.4, 2.4, 0, D.BLK, 1.5)
D.px(37, 42, "#e6bc50") D.px(38, 43, "#e6bc50") D.px(40, 43, "#c89a38") D.px(39, 42, "#f4d676") D.px(41, 42, "#c89a38")
D.fin()
