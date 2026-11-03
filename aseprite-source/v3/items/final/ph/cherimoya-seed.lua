-- cherimoya-seed (v3 first draft, dB15). quirk: a seed split open shows a pale green embryo
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cherimoya-seed")
D.scrap(c, "moss", { w = 9 })
local SEED = { "#1c1010", "#2e1a16", "#4a2a20", "#6a3e2c", "#8e5a3c", "#b88458" }
D.seed(c, 14, 50, 5, 3, -0.3, SEED)
D.seed(c, 26, 54, 5, 3, 0.2, SEED)
c:px(11, 52, "#e8d8b0") c:px(23, 56, "#e8d8b0")
-- split seed, sprout
D.seed(c, 38, 50, 5.4, 3.4, -0.6, SEED)
B.ln(c, 36, 52, 40, 48, "#d8e4a4")
D.stem(c, { {40, 48}, {42, 40}, {40, 32}, {42, 24} }, 0.9, 0.8, "moss")
H.leaf(c, 42, 24, 54, 16, 4.2, "moss", { 3, 7 })
H.leaf(c, 41, 28, 28, 22, 4.2, "moss", { 3, 7 })
H.lit(c, B.ell(42, 22, 1.6, 2, 0), "moss", { R = 1 })
D.fin()
