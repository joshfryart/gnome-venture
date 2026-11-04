-- mulberry-seed: four pale tan teardrop seeds on a leaf scrap; sprout with two cotyledons and a lobed heart-shaped mulberry leaf. quirk: one seed wears a tiny purple berry-skin cap.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mulberry-seed")
D.scrap(c, { ramp = "moss", y0 = 56, y1 = 50 })
local LF = D.R("#c4e07a", "#7cc35a", "#3f9150", "#24544a")
D.stem(c, { {32,48}, {31,40}, {33,32} }, 1, "#7a8a48", "#b7c46a")
B.lit(c, B.ell(26, 41, 4, 2.2, 0.5), LF, 1.6) B.lit(c, B.ell(37, 43, 4, 2.2, -0.4), LF, 1.6)
local m = D.heart(c, 34, 24, 11, -1.4, LF, true)
for _, p in ipairs{ {24,19}, {44,19}, {26,28}, {42,27} } do c:px(p[1], p[2], LF.deep) end
local TAN = D.R("#fff0c4", "#e8c070", "#b88a48", "#6e4a30")
for _, s in ipairs{ {14,51,0.4}, {24,53,-0.5}, {44,52,0.2}, {53,50,2.4} } do B.seed(c, s[1], s[2], 3.2, 2.1, s[3], TAN, "#1f553f") end
B.lit(c, B.ell(44, 51, 2.8, 2, 0.4), D.R("#b49af0", "#6a4cb8", "#42307e", "#241a4e"), 1.6)
c:px(43, 50, "#e0d4ff")
D.fin()
