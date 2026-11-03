local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-chili")
local CR, INK = D.CR, D.INK
-- ico-chili: curved red pepper with a long hooked tip, glossy streak, green cap with a curling stem.
-- quirk: a tiny flame licks off the tip and a sweat drop beads on the shoulder.
local m = D.H.sweep({ {20, 18}, {44, 14}, {52, 36}, {30, 56} }, function(t) return 8 * (1 - t) ^ 0.7 + 0.8 end, 70)
D.lit(m, D.RED, 5, { amb = 0.08 })
D.poly(c, { {26, 17}, {40, 17}, {46, 26} }, D.RED[6]) D.px(27, 18, D.CR)
D.lit(c:rect(15, 14, 24, 21):add(c:ellipse(19, 19, 6, 5)), D.GREEN, 3)
D.px(16, 16, D.GREEN[6]) D.px(17, 16, D.GREEN[6])
D.poly(c, { {16, 14}, {13, 8}, {9, 6}, {8, 9} }, "#2f8450")
D.lit(c:line({ {16, 15}, {14, 9}, {10, 6} }, 3), D.GREEN, 1.5)
D.fill(c:poly{ {24, 56}, {19, 62}, {24, 60}, {27, 63}, {29, 58} }, "#ff9f3c"); D.fill(c:poly{ {24, 57}, {22, 60}, {26, 59} }, "#ffe27a")
D.fill(c:rect(48, 18, 49, 20), "#8bc4ea"); D.px(48, 17, "#8bc4ea") D.px(48, 18, CR)
D.fin()
