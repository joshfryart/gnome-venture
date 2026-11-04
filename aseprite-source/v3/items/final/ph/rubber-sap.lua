-- rubber-sap (first draft, Sonnet). A tapped rubber-tree trunk: bark with a diagonal groove, a tin spout, and a
-- fat creamy drop of latex falling into a small clay cup brimming with milky sap.
-- quirk: a big bubble is rising on the surface of the latex.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rubber-sap")
c:groundShadow(38, 58, 12, 3)
local ox = 6
-- trunk
local tr = c:rect(8 + ox, 8, 26 + ox, 56)
A.lit(c, tr, "#8a6a52", 4, { amb = .12 })
tr:each(function(x, y) if (x + math.floor(y / 5)) % 4 == 0 then c:px(x, y, "#5a3e32") end end)
A.speck(c, tr, { "#a8866a", "#4a3028" }, .07, 11)
-- cut end on top
local top = c:ellipse(17 + ox - .5, 8, 9.5, 3.2)
A.lit(c, top, "#e8b982", 2)
for _, r in ipairs{ 7, 4 } do for x = 17 + ox - r, 17 + ox + r do c:px(x, 8 + (r > 5 and 1 or 0), "#b97a4a") end end
-- groove
for i = 0, 14 do c:px(10 + ox + i, 20 + i, "#2b1c26") c:px(10 + ox + i, 21 + i, "#51302b") end
for i = 0, 12 do c:px(11 + ox + i, 22 + i, "#f4efe0") end
-- spout
A.rod(c, 23 + ox, 34, 32 + ox, 36, 1.2, "#aaa9b8", { amb = .12 })
A.lit(c, c:rect(32 + ox, 35, 33 + ox, 38), "#aaa9b8", 1)
-- drop
local lt = A.R("#f4ecd8")
A.sph(c, 33 + ox, 43, 2.8, lt, { spec = "#fff4d6" })
A.ln(c, 33 + ox, 39, 33 + ox, 41, "#f4ecd8")
-- cup
local cup = c:ellipse(37.5 + ox, 54, 10, 7):clip(c:rect(0, 49, 63, 63)):add(c:rect(28 + ox, 49, 46 + ox, 53))
A.lit(c, cup, "#c0603a", 3, { amb = .1 })
local rimm = c:ellipse(37.5 + ox, 49, 10, 2.6)
A.lit(c, rimm, "#e0904a", 1.6)
local milk = c:ellipse(37.5 + ox, 49, 8, 1.8)
A.lit(c, milk, lt, 1.4)
A.sph(c, 40 + ox, 46, 2.2, "#fff4d6", { nospec = true }) c:px(39 + ox, 45, "#ffffff" and "#fffbe8")
A.fin()
