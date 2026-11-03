local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-jar: glass jar of red jam with a gold lid and cream label. quirk: a drip of jam runs down the glass.
local c = D.new("ico-jar")
local body = c:rrect(14, 20, 50, 56, 7)
D.lit(body, "sea", 5)
local jam = c:rrect(16, 26, 48, 54, 6)
D.cyl(jam, D.RED, 16, 48)
D.lit(c:rect(16, 26, 48, 29), D.RED, 1)
D.fill(c:rect(24, 34, 40, 46), D.CREAM[4]) D.fill(c:rect(24, 34, 40, 35), D.CREAM[6]) D.fill(c:rect(24, 45, 40, 46), D.CREAM[2])
D.fill(c:rect(28, 38, 36, 39), D.RED[3]) D.fill(c:rect(28, 41, 33, 42), D.RED[3])
D.lit(c:rrect(17, 10, 47, 21, 3), D.GOLD, 2)
for x = 21, 43, 4 do D.fill(c:rect(x, 13, x, 19), D.GOLD[2]) end
D.fill(c:rect(18, 20, 46, 20), D.GOLD[1])
D.px(18, 31, "#e4f6ff") D.px(18, 32, "#e4f6ff") D.px(18, 33, "#e4f6ff")
D.fill(c:rect(22, 20, 24, 28), D.RED[4]) D.px(22, 21, D.RED[6]) D.fill(c:rect(22, 29, 24, 29), D.RED[3])
D.fin()
