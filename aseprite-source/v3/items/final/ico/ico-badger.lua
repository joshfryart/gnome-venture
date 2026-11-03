local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-badger: bold front-on badger head, white face split by two charcoal stripes through the eyes, round ears.
-- quirk: a tiny white daisy is tucked behind the right ear.
local c = D.new("ico-badger")
local CH = { hi = "#7a7a94", base = "#5a5a72", shade = "#444663", deep = "#2e2f48" }
local WH = { hi = "#fffaf0", base = "#fff4d6", shade = "#d8d0c0", deep = "#9a90a0" }
-- ears
c:part(c:ellipse(15, 15, 6, 6), CH)
c:part(c:ellipse(49, 15, 6, 6), CH)
c:fillMask(c:ellipse(15, 16, 3, 3), "#9a90a0") c:fillMask(c:ellipse(49, 16, 3, 3), "#9a90a0")
-- head
local head = c:ellipse(32, 35, 20, 18)
c:part(head, WH, { band = 3 })
-- dark stripes
local l = c:poly{ {13, 22}, {25, 20}, {28, 38}, {26, 50}, {18, 46}, {12, 36} }:clip(head)
local r = c:poly{ {51, 22}, {39, 20}, {36, 38}, {38, 50}, {46, 46}, {52, 36} }:clip(head)
c:part(l, CH, { inner = false, band = 2 }) c:part(r, CH, { inner = false, band = 2 })
-- snout and nose
c:part(c:ellipse(32, 43, 6, 5), WH, { band = 1, noshade = true, nopop = true })
c:part(c:ellipse(32, 38, 4, 3), { hi = "#4a3a4a", base = "#2b1c26", shade = "#2b1c26", deep = "#2b1c26" }, { noshade = true, nopop = true, inner = false })
c:px(31, 37, CREAM) c:px(30, 37, "#7a7a94")
D.polyline(c, { {32, 41}, {32, 44} }, "#444663")
D.polyline(c, { {29, 46}, {32, 48}, {35, 46} }, "#444663")
-- eyes (cream ring so they read on charcoal)
c:fillMask(c:rect(22, 29, 25, 33), "#fff4d6") c:fillMask(c:rect(39, 29, 42, 33), "#fff4d6")
c:eyeSmall(23, 30) c:eyeSmall(40, 30)
-- daisy
for _, p in ipairs{ {55, 8}, {53, 10}, {57, 10}, {55, 12} } do c:fillMask(c:rect(p[1] - 1, p[2] - 1, p[1] + 1, p[2] + 1), "#fffaf0") end
c:fillMask(c:rect(54, 9, 56, 11), "#f5b82e")
D.move(c, -3, 2)
D.fin()
