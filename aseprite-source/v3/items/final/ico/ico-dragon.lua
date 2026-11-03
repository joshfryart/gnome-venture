local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-dragon: chunky green dragon in profile, curled tail, bat wing, two horns, cream belly.
-- quirk: it puffs a tiny heart-shaped smoke cloud from its nostril.
local c = D.new("ico-dragon")
local G = { "#14382f", "#1f5a44", "#2f8450", "#3fa862", "#6cc880", "#aeeaa0" }
-- wing
D.lit(c:poly{ { 26, 32 }, { 10, 8 }, { 20, 14 }, { 26, 8 }, { 32, 16 }, { 38, 30 } }, D.RED, 3)
D.fill(c:line({ { 26, 32 }, { 12, 10 } }, 1), D.RED[2]) D.fill(c:line({ { 28, 30 }, { 26, 10 } }, 1), D.RED[2])
-- tail
D.lit(c:line({ { 22, 42 }, { 12, 50 }, { 6, 48 }, { 6, 42 } }, 5), G, 2.5)
D.fill(c:poly{ { 3, 42 }, { 6, 36 }, { 9, 42 } }, D.RED[3])
-- legs
D.lit(c:line({ { 24, 46 }, { 22, 57 } }, 5), G, 2)
D.lit(c:line({ { 36, 46 }, { 38, 57 } }, 5), G, 2)
D.fill(c:rect(19, 56, 25, 58), D.CREAM[3]) D.fill(c:rect(35, 56, 41, 58), D.CREAM[3])
-- body, neck, head
D.lit(D.ell(30, 40, 14, 9, 0), G, 6)
D.fill(D.isect(D.ell(31, 45, 11, 4), c:rect(0, 44, 63, 63)), D.CREAM[4])
D.lit(c:line({ { 38, 36 }, { 44, 22 } }, 7), G, 3)
D.lit(D.ell(47, 17, 7, 5.2, 0.2), G, 4)
D.lit(D.ell(53, 20, 4, 3, 0.2), G, 2)
D.px(55, 19, D.INK) D.px(48, 15, D.INK) D.px(47, 14, D.CR) D.px(48, 14, D.CR)
-- horns + spines
D.fill(c:poly{ { 42, 14 }, { 38, 6 }, { 46, 11 } }, D.CREAM[4])
D.fill(c:poly{ { 47, 11 }, { 48, 4 }, { 52, 11 } }, D.CREAM[3])
for _, p in ipairs{ { 24, 31 }, { 30, 31 }, { 36, 33 } } do D.fill(c:poly{ { p[1] - 2, p[2] + 1 }, { p[1], p[2] - 3 }, { p[1] + 2, p[2] + 1 } }, D.RED[3]) end
-- heart smoke
local h = c:poly{ { 56, 11 }, { 57, 9 }, { 59, 10 }, { 61, 9 }, { 62, 11 }, { 59, 15 } }:add(c:rect(57, 9, 61, 11))
D.fill(h, D.CREAM[4])
D.fin()
