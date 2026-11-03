-- chayote-seed (v3 first draft, dB15). quirk: the seedling's tendril corkscrews up
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("chayote-seed")
D.scrap(c, "moss", { w = 7 })
local SEED = { "#9a8a62", "#c4b484", "#e0d2a4", "#f0e6c0", "#faf2d8", "#fffaee" }
D.seed(c, 20, 47, 8, 4.8, -0.2, SEED)
B.ln(c, 14, 46, 26, 45, SEED[2])
D.seed(c, 44, 52, 5, 3, 0.3, SEED)
-- root nub
H.lit(c, B.ell(29, 44, 2, 1.4, -0.3), SEED, { R = 1 })
D.stem(c, { {28, 44}, {30, 36}, {34, 30}, {34, 22} }, 0.9, 0.8, "moss")
local leaf = c:poly{ {34, 22}, {24, 18}, {23, 10}, {30, 6}, {38, 8}, {46, 12}, {44, 19} }
H.lit(c, leaf, "moss", { R = 2.5 })
B.ln(c, 34, 22, 33, 9, "#c4e07a", leaf) B.ln(c, 34, 18, 26, 12, "#3f9150", leaf) B.ln(c, 34, 18, 42, 13, "#3f9150", leaf)
B.polyline(c, { {32, 34}, {40, 32}, {44, 34}, {44, 38}, {41, 38}, {41, 35}, {43, 35} }, "#4a9a50")
D.fin()
