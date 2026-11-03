local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-carrot")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-carrot: fat tapered carrot on a lean, ringed with pale grooves, three feathery leaves on top.
-- quirk: a small bite-hole low on the side with a pink worm peeking out.
D.leaf(30, 21, 20, 6, 4, "moss", { 3 })
D.leaf(32, 21, 33, 4, 4, "moss", { 4 })
D.leaf(34, 21, 45, 7, 4, "moss", { 3 })
local m = D.H.sweep({ {30, 18}, {33, 30}, {37, 44}, {40, 59} }, function(t) return 10.5 * (1 - t) ^ 0.75 + 0.5 end, 60)
m:cut(c:rect(0, 0, 63, 15))
D.lit(m, D.ORG, 6, { amb = 0.1 })
for _, p in ipairs{ {27, 28, 33}, {28, 35, 34}, {31, 41, 36}, {35, 47, 38} } do D.fill(c:rect(p[1], p[2], p[3], p[2]), D.ORG[2]) D.px(p[1] + 1, p[2] - 1, D.ORG[5]) end
D.px(28, 22, D.ORG[6]) D.px(29, 22, D.ORG[6])
D.fill(c:ellipse(40, 36, 2, 2), "#4a1a14")
D.poly(c, { {41, 36}, {44, 34}, {46, 35} }, "#f5809f")
D.px(46, 35, "#fff4d6")
D.fin()
