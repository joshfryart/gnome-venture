local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-burst")
local CR = D.CR
-- ico-burst: bold 10-point comic spark star, orange rim, golden middle, cream hot core.
-- quirk: one spike has snapped off and flies away as its own little shard.
local out = D.star(32, 32, 10, -1.57, function(i) return i % 2 == 0 and ({ 25, 22, 25, 20, 24 })[(i // 2) % 5 + 1] or 12 end)
D.lit(out, D.ORG, 7, { amb = 0.1 })
local mid = D.star(32, 32, 10, -1.57, function(i) return i % 2 == 0 and 14 or 8 end)
D.lit(mid, D.YEL, 5, { amb = 0.2 })
D.lit(c:ellipse(31, 31, 5, 5), { "#ffe27a", "#fff0a8", "#fff6c0", CR, CR, "#fffdf2" }, 4, { amb = 0.4 })
D.px(28, 28, "#fffdf2") D.px(29, 28, "#fffdf2")
-- flying shard + sparks
D.fill(c:poly{ {54, 8}, {60, 6}, {57, 13} }, "#ff9f3c") D.px(57, 8, CR)
D.fill(c:rect(56, 17, 58, 19), "#ffc84a") D.fill(c:rect(6, 8, 8, 10), "#ffc84a") D.fill(c:rect(5, 52, 7, 54), "#ff9f3c")
D.fin()
