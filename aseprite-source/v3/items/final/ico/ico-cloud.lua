local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-cloud")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-cloud: fat three-bump cloud, flat bottom, pale blue shade on the underside with a cream top light.
-- quirk: a small sun peeks from behind the top right, and one raindrop falls from the belly.
D.lit(ell(46, 20, 11, 11, 0), D.YEL, 5, { amb = 0.2 })
for _, a in ipairs{ {46, 3, 46, 6}, {58, 10, 61, 8}, {58, 24, 61, 26} } do D.fill(c:rect(a[1], a[2], a[1] + 1, a[4]), D.YEL[4]) end
local m = ell(21, 40, 11, 10, 0):add(ell(33, 30, 14, 14, 0)):add(ell(46, 38, 11, 10, 0)):add(c:rect(14, 38, 50, 49))
m:clip(c:rect(0, 0, 63, 49))
D.lit(m, D.SKY, 12, { amb = 0.12, wrap = 0.35 })
D.px(27, 22, D.CR) D.px(28, 21, D.CR) D.px(29, 21, D.CR)
D.fill(c:poly{ {32, 52}, {35, 57}, {32, 59}, {29, 57} }, "#4a8acc"); D.px(31, 56, D.CR)
D.fin()
