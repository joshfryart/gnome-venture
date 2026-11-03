local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-island: sandy mound with a leaning palm in a sea disc. quirk: a shark fin circles the island.
local c = D.new("ico-island")
local sea = D.ell(32, 48, 25, 9) D.lit(sea, "sea", 4)
for _, p in ipairs{{12,48},{13,48},{50,46},{51,46},{22,53},{23,53},{40,53}} do D.px(p[1], p[2], "#b6f0e0") end
D.lit(D.ell(30, 44, 15, 7), D.SAND, 4)
D.lit(c:poly{{46,43},{50,36},{53,43}}, D.SILV, 1)   -- fin
D.px(51, 40, D.SILV[6])
-- trunk
D.lit(D.seg({{30,43},{29,32},{32,22},{36,16}}, 3), D.BARK, 1.5)
for _, y in ipairs{40, 35, 30, 25} do D.px(30, y, D.BARK[1]) end
-- fronds
for _, f in ipairs{ {36,16, 20,16, 6}, {36,16, 22,28, 5}, {36,16, 54,14, 6}, {36,16, 52,26, 5}, {36,16, 36,4, 4} } do
  D.leaf(f[1], f[2], f[3], f[4], f[5], "moss", {5, 9})
end
D.lit(D.ell(34, 19, 2.2, 2.2), D.BRN, 1.5) D.lit(D.ell(38, 19, 2.2, 2.2), D.BRN, 1.5)
D.fin()
