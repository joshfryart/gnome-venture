local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-cake")
local CR, INK = D.CR, D.INK
-- ico-cake: two-tier sponge with a thick strawberry-pink icing cap and drips, one candle, cherry on top.
-- quirk: a big bite is missing from the right side, crumbs on the plate.
c:groundShadow(32, 57, 20, 2)
local body = c:rrect(11, 28, 53, 54, 4)
body:cut(c:ellipse(54, 30, 7, 6))
D.lit(body, D.CRUST, 6, { amb = 0.15 })
D.rect(11, 42, 47, 42, "#fff0cc"); D.rect(11, 41, 47, 41, "#a8341c")   -- jam layer
D.lit(c:rect(11, 41, 47, 42), D.PINK, 1)
local ic = c:rrect(9, 22, 55, 33, 4)
ic:cut(c:ellipse(54, 30, 7, 6))
for _, d in ipairs{ {14, 38}, {22, 36}, {30, 39}, {39, 36} } do ic:add(c:rrect(d[1], 30, d[1] + 3, d[2], 1)) end
D.lit(ic, D.PINK, 4, { amb = 0.12 })
D.lit(c:rrect(30, 12, 33, 22, 1), { "#4a8acc", "#78b4ea", "#b6dcf6", "#fffdf2", "#fffdf2", "#fffdf2" }, 1.5)
D.fill(c:poly{ {31, 6}, {34, 11}, {29, 11} }, "#ffbf5c"); D.px(31, 9, CR)
D.lit(c:ellipse(43, 21, 4, 4), D.RED, 3); D.px(42, 19, CR)
D.px(55, 52, "#b8702f") D.px(58, 55, "#b8702f") D.px(52, 56, "#d6903f")
D.fin()
