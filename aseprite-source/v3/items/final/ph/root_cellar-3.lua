-- root_cellar-3 (first draft, Sonnet). Tier 3: the full cellar. Stone frame under a timber beam with a hanging
-- carrot sign, two stone steps, a small barrel by the door, stovepipe, flag.
-- quirk: a hanging wooden sign swings from the beam with a tiny carrot painted on it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("root_cellar-3")
c:groundShadow(32, 59, 25, 3)
local m = A.mound(c, { cx = 30, yb = 52, rx = 25, ry = 32, ramp = "moss", skew = -1 })
A.speck(c, m, { "#c4e07a", "#3f9150" }, .09, 9)
A.lit(c, c:rect(4, 52, 55, 54), "wood", 1.6)
local pipe = c:rect(46, 24, 50, 34) A.lit(c, pipe, "stone", 1.8) A.lit(c, c:rect(44, 21, 52, 24), "stone", 1.5)
local fr = A.archM(c, 30, 52, 10, 21)
A.lit(c, fr, "stone", 2.4, { amb = .12 })
for _, p in ipairs{ { 21, 42 }, { 21, 48 }, { 39, 40 }, { 39, 46 }, { 28, 33 }, { 34, 33 } } do c:px(p[1], p[2], "#74758c") c:px(p[1] + 1, p[2], "#74758c") end
A.door(c, 30, 52, 7, 17, "wood")
-- beam
A.lit(c, c:rect(17, 30, 43, 33), "wood", 1.8)
for x = 20, 40, 5 do c:px(x, 31, "#51302b") end
-- sign
A.ln(c, 22, 34, 22, 36, "#444663") A.ln(c, 28, 34, 28, 36, "#444663")
A.lit(c, c:rect(20, 37, 30, 42), "#d9a070", 1.4)
A.sph(c, 25, 40, 1.6, "#f08a2a", { nospec = true }) c:px(25, 38, "#5ab050")
-- steps
A.lit(c, c:rect(18, 52, 42, 54), "stone", 1.2) A.lit(c, c:rect(15, 55, 45, 57), "stone", 1.2)
-- barrel
A.lit(c, c:rect(5, 45, 13, 53), "wood", 2) c:fillMask(c:rect(5, 47, 13, 47), "#444663") c:fillMask(c:rect(5, 51, 13, 51), "#444663")
c:px(8, 45, "#e8b982")
-- flag
A.fin()
