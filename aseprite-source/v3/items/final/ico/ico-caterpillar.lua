local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-caterpillar")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-caterpillar: five fat leaf-green segments in an arch, big round face with eyes, little smile and two knobbed feelers.
-- quirk: wears a tiny yellow daisy on its back.
local seg = { {10, 46, 5}, {19, 50, 5.5}, {29, 51, 6}, {39, 47, 6}, {47, 37, 6.5} }
for i = 1, #seg do local s = seg[i] D.lit(D.ell(s[1], s[2], s[3], s[3], 0), D.GREEN, s[3] - 0.5, { amb = 0.1 }) end
for i = 1, 4 do local s = seg[i] D.fill(c:rect(s[1] - 3, s[2] + 6, s[1] - 2, s[2] + 8), "#8a4a1f"); D.fill(c:rect(s[1] + 1, s[2] + 6, s[1] + 2, s[2] + 8), "#8a4a1f") end
for i = 1, 5 do local s = seg[i] D.px(floor and s[1] or s[1], s[2] - s[3] + 1, D.GREEN[6]) end
D.lit(D.ell(50, 24, 9, 9, 0), D.GREEN, 7, { amb = 0.1 })
D.poly(c, { {46, 17}, {43, 10}, {41, 8} }, "#14382f") D.poly(c, { {53, 17}, {55, 10}, {58, 8} }, "#14382f")
D.lit(D.ell(41, 8, 2.5, 2.5, 0), D.RED, 2) D.lit(D.ell(58, 8, 2.5, 2.5, 0), D.RED, 2)
c:eyeSmall(46, 21) c:eyeSmall(52, 21)
D.px(48, 29, INK) D.px(49, 30, INK) D.px(50, 30, INK) D.px(51, 29, INK)
D.px(44, 27, "#f5809f") D.px(45, 27, "#f5809f") D.px(54, 27, "#f5809f") D.px(55, 27, "#f5809f")
-- daisy
for _, p in ipairs{ {29, 40}, {25, 43}, {33, 43}, {27, 47}, {31, 47} } do end
for _, p in ipairs{ {29, 41}, {25, 44}, {33, 44}, {27, 48}, {31, 48} } do D.fill(c:rect(p[1] - 1, p[2] - 1, p[1] + 1, p[2]), D.CR) end
D.fill(c:rect(28, 44, 30, 46), D.YEL[4]); D.px(28, 44, D.YEL[5])
D.fin()
