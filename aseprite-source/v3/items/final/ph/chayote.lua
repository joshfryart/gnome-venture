-- chayote (v3 first draft, dB15). quirk: a curly tendril still clings to the stem
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("chayote")
D.shadow(c, 30, 54, 16, 3)
local CH = { "#2f5a3a", "#4f8a4a", "#7fb35c", "#a6d278", "#c8e69a", "#e8f6c4" }
local body = B.ell(30, 38, 15, 14, 0):add(B.ell(30, 24, 8, 8, 0))
H.lit(c, body, CH, { R = 5 })
-- the groove and wrinkles
B.ln(c, 30, 20, 30, 40, CH[2], body) B.ln(c, 30, 40, 31, 52, CH[2], body)
for _, p in ipairs{ {22, 30}, {23, 31}, {38, 36}, {39, 37}, {24, 44}, {25, 45}, {36, 46}, {35, 27}, {26, 26} } do c:px(p[1], p[2], CH[3]) end
for _, p in ipairs{ {26, 42}, {34, 34}, {36, 44}, {22, 38} } do c:px(p[1], p[2], CH[2]) end
-- bottom fold
B.polyline(c, { {26, 50}, {30, 52}, {34, 50} }, CH[1], body)
-- stem nub
H.lit(c, c:rect(28, 14, 31, 17), "wood", { R = 1 })
-- tendril
B.polyline(c, { {31, 15}, {36, 12}, {40, 13}, {41, 17}, {38, 18}, {37, 15}, {39, 15} }, "#3f9150")
B.polyline(c, { {38, 12}, {41, 10} }, "#7cc35a")
D.fin()
