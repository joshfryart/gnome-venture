-- ico-page first draft (Sonnet). quirk: a red wax seal with trailing ribbon is pressed at the bottom
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-page")
local PAP = { "#a89070", "#c9b48f", "#e6d5b0", "#f2e6c4", "#fbf1d4", "#fffbe8" }
c:groundShadow(30, 58, 17, 2)
local pg = c:rect(13, 6, 47, 56):cut(c:poly{ {38, 6}, {47, 6}, {47, 15} })
D.lit(pg, PAP, 3, { amb = .12 })
D.fill(c:poly{ {38, 6}, {47, 15}, {38, 15} }, "#c9b48f") D.fill(c:poly{ {38, 7}, {46, 15}, {38, 15} }, "#a89070")
D.fill(c:rect(38, 15, 47, 15), "#a89070")
-- title scribble + lines
D.fill(c:rect(17, 10, 31, 13), "#51302b")
for i, y in ipairs{ 19, 24, 29, 34, 39 } do D.fill(c:rect(17, y, i == 5 and 33 or 43, y + 1), "#74758c") end
-- ribbon tails and wax seal
D.fill(c:poly{ {26, 44}, {33, 44}, {30, 59}, {27, 56}, {23, 59} }, "#3a6aa6") D.fill(c:rect(29, 44, 29, 56), "#4a8acc")
D.lit(D.ell(30, 46, 7, 7), "ember", 3)
D.fill(D.ell(30, 46, 4, 4), "#b52e3f") D.fill(c:rect(29, 44, 31, 48), "#e8493b") c:px(28, 43, "#ff8a5c")
D.fill(c:rect(24, 40, 25, 41), "#e8493b") D.fill(c:rect(36, 51, 37, 52), "#e8493b")
D.fin()
