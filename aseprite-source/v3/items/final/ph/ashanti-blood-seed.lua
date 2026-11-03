local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA13.lua")
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local c = D.new("ashanti-blood-seed")
-- ashanti-blood-seed: tiny dark specks of Mussaenda seed on a fuzzy oval leaf scrap; seedling has opposite ovate leaves and one blood-red petal-like bract. quirk: the red bract is already bigger than the seedling's real leaves.
D.scrap(10, 54, 50, 46, 7, {"#1f4a2c","#2f6a3a","#4a8a48","#6aaa56","#8cc66a","#b4e08a"})
-- seeds: cluster of tiny specks
local S = D.SEED
for _, p in ipairs{{18,50},{22,52},{26,50},{20,47},{30,53},{24,48},{34,50},{16,53}} do
  D.E(p[1], p[2], 1.6, 1.2, p[1] * 0.3, S, 1) D.px(p[1] - 1, p[2] - 1, "#d8c090")
end
-- seedling
D.stem2(34, 48, 34, 28)
D.lf(28, 36, 4.2, 2.4, -0.4, D.LEAF2) D.lf(40, 36, 4.2, 2.4, 0.4, D.LEAF2)
D.lf(30, 28, 3.4, 2, -0.5, D.LEAF) D.lf(38, 28, 3.4, 2, 0.5, D.LEAF)
-- red bract
D.P({{34,26},{26,18},{28,10},{36,8},{44,12},{42,20}}, {"#5a1228","#8a1c34","#b82c3c","#dc4040","#f06450","#ff9068"}, 3)
D.ln(34, 25, 35, 12, "#8a1c34") D.ln(30, 17, 34, 20, "#b82c3c")
D.E(34, 26, 1.5, 1.5, 0, D.YEL, 1)
D.fin()
