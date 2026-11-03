local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-check")
local CR, INK = D.CR, D.INK
-- ico-check: very bold tick, short stroke and a long rising stroke with rounded ends, glossy green.
-- quirk: a tiny two-leaf sprout grows from the tip of the long stroke.
local m = c:line({ {12, 33}, {25, 46}, {50, 16} }, 9)
m:add(c:ellipse(12, 33, 4.5, 4.5)):add(c:ellipse(50, 16, 4.5, 4.5))
D.lit(m, D.GREEN, 4.5, { amb = 0.1 })
D.poly(c, { {14, 31}, {25, 42}, {48, 14} }, D.GREEN[6])
D.px(10, 30, D.GREEN[6])
D.rect(54, 7, 54, 12, "#2f8450")
D.leaf(54, 8, 49, 3, 3, "moss", { 2 })
D.leaf(54, 8, 60, 4, 3, "moss", { 2 })
D.fin()
