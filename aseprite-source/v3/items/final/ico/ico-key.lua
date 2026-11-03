local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-key: diagonal gold key with a clover bow. quirk: a green ribbon is tied through the bow.
local c = D.new("ico-key")
D.lit(D.seg({{26,26},{50,50}}, 5), D.GOLD, 2)
for _, t in ipairs{ {38,38,32,44,3}, {44,44,38,50,3} } do D.lit(D.seg({{t[1],t[2]},{t[3],t[4]}}, 4), D.GOLD, 1.5) end
D.lit(D.ell(52, 52, 2, 2), D.GOLD, 1)
local bow = D.disc(18, 18, 11)
D.lit(bow, D.GOLD, 5)
D.fill(D.disc(18, 18, 4), D.GOLD[1]) D.fill(D.disc(18, 18, 3), D.GOLD[2])
D.lit(D.seg({{22,22},{12,34},{6,44}}, 3), D.GREEN, 1)
D.lit(D.seg({{24,20},{34,10},{44,8}}, 3), D.GREEN, 1)
D.fin()
