-- ico-salad first draft. cream bowl heaped with leaves, tomato and cucumber. quirk: a fork stuck in, spearing a cherry tomato
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-salad")
c:groundShadow(32, 56, 22, 3)
-- fork
D.polyline(c, { {50, 8}, {40, 28} }, "#a4a8c0") D.polyline(c, { {51, 8}, {41, 28} }, "#7e829e")
D.lit(c, c:poly{ {47, 3}, {55, 3}, {56, 13}, {47, 13} }:clip(c:ellipse(51, 12, 5, 9)), D.GRY, 1.5)
-- greens
local gr = { {20, 30, 8, 7}, {28, 24, 8, 7}, {38, 28, 9, 7}, {46, 33, 6, 5}, {16, 36, 6, 5}, {33, 33, 8, 6} }
local tones = { D.GRN, "moss", D.GRN, "moss", D.GRN, "moss" }
for i, g in ipairs(gr) do D.lit(c, D.ell(g[1], g[2], g[3], g[4], (i % 2 - .5) * .6), tones[i], 2.8) end
-- veins on leaves
D.polyline(c, { {24, 28}, {30, 22} }, "#c4e07a") D.polyline(c, { {36, 30}, {43, 26} }, "#aeeaa0")
-- tomatoes
D.lit(c, c:ellipse(24, 33, 4, 4), D.RED, 3) c:px(23, 31, "#ffd8c8")
D.lit(c, c:ellipse(36, 20, 3.5, 3.5), D.RED, 3) c:px(35, 18, "#ffd8c8")
-- cucumber slice
D.lit(c, c:ellipse(44, 31, 4, 4), "moss", 2.5)
D.lit(c, c:ellipse(44, 31, 2, 2), D.CRM, 1) c:px(44, 31, "#3f9150")
-- bowl
local bowl = D.ell(32, 36, 23, 20):clip(c:rect(0, 36, 63, 63))
bowl:add(c:rect(9, 36, 55, 40)) bowl:clip(D.ell(32, 36, 23, 20):add(c:rect(9, 36, 55, 38)))
D.lit(c, bowl, D.CRM, 7, { amb = 0.12 })
D.R(c, 9, 36, 55, 38, "#8a6a5a") D.R(c, 9, 36, 55, 36, "#a88a6a")
D.pts(c, { {13, 40}, {14, 41}, {15, 42} }, "#fffbec")
D.fin()
