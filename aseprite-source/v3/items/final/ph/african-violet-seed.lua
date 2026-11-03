local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA12.lua")
local HP, B, H, X = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- african-violet-seed: a pinch of dust-fine dark seeds beside a papery seed capsule, on a round scalloped fuzzy leaf; sprout is two tiny round hairy leaves. quirk: a single seed has landed on its own tiny leaf.
local c = D.new("african-violet-seed")
local LV = {"#1c4a3a","#2b6b45","#3f8a4e","#5aaa58","#86c868","#bfe688"}
local lf = D.ell(30, 44, 22, 11, -0.08)
D.lit(lf, LV, 6)
for i = 0, 14 do local a = i / 15 * 2 * pi c:px(floor(30+cos(a)*22+.5), floor(44+sin(a)*11+.5), LV[(i%2==0) and 4 or 3]) end
for _, p in ipairs{{14,40},{20,38},{26,36},{34,36},{41,38},{47,41},{18,48},{26,50},{38,50},{46,47}} do c:px(p[1], p[2], "#bfe688") end
-- veins
D.ln(30,44,30,34,"#bfe688") D.ln(30,44,15,41,"#5aaa58") D.ln(30,44,46,42,"#5aaa58") D.ln(30,44,22,52,"#2b6b45") D.ln(30,44,40,52,"#2b6b45")
-- dust seeds
for _, p in ipairs{{20,46},{22,49},{25,47},{27,45},{23,44},{29,49},{31,47},{19,43},{26,51},{33,50}} do c:fillMask(c:rect(p[1],p[2],p[1]+1,p[2]), "#2e1c1c") c:px(p[1], p[2], "#6a4030") end
-- capsule
D.lit(D.ell(41, 46, 3.4, 4.2, 0.3), D.TAN, 2.4) c:px(41,44,"#8f6a46") c:px(41,45,"#8f6a46") c:px(41,46,"#2e1c1c")
-- sprout
D.stem(32, 41, 32, 29, "#a8c27a") D.stem(33, 41, 33, 29, "#7c9a58")
D.lf(27, 27, 4.4, 3.8, 0, LV) D.lf(38, 27, 4.4, 3.8, 0, LV)
for _, p in ipairs{{24,24},{26,23},{28,23},{37,23},{39,23},{41,24}} do c:px(p[1], p[2], "#bfe688") end
-- quirk: seed on mini leaf
D.lf(11, 33, 3.2, 1.8, -0.6, D.LEAF) c:px(10,31,"#2e1c1c") c:px(11,31,"#6a4030")
D.fin()
