-- cheese-wheel (v3 first draft, dB15). quirk: a mouse perches on the top, tail trailing down
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cheese-wheel")
D.shadow(c, 30, 52, 24, 3)
local CH = { "#8f4a1f", "#d98322", "#ee9e2a", "#f5b82e", "#ffd45a", "#ffeb98" }
local top = B.ell(30, 26, 22, 10, 0)
local side = c:rect(8, 26, 52, 42):add(B.ell(30, 42, 22, 10, 0)):cut(top)
local wedge = c:poly{ {30, 26}, {56, 16}, {56, 52}, {30, 52} }:cut(c:poly{ {30, 26}, {56, 16}, {56, 30} }):shift(0, 0)
local gone = c:poly{ {30, 27}, {58, 14}, {58, 56}, {30, 56} }:clip(c:poly{ {30, 27}, {58, 27}, {58, 50}, {30, 50} })
local wheel = top:copy():add(side)
local cutm = c:poly{ {30, 26}, {58, 20}, {58, 44}, {40, 44}, {30, 36} }
wheel:cut(cutm)
H.vcyl(c, side:copy():cut(cutm), CH, 8, 52)
H.lit(c, top:copy():cut(cutm), CH, { R = 3 })
-- cut faces (pale paste with eyes)
local face = c:poly{ {30, 27}, {30, 36}, {40, 44}, {50, 44}, {50, 36}, {40, 30} }
H.lit(c, face, { "#c8741f", "#e8962a", "#f6b832", "#ffd45a", "#ffe58a", "#fff4c0" }, { R = 2 })
for _, p in ipairs{ {34, 33}, {41, 38}, {46, 40} } do H.lit(c, c:ellipse(p[1], p[2], 1.2, 1.2), { "#8f4a1f", "#b8601f", "#d98322", "#e8a02a", "#f5b82e", "#ffd45a" }, { R = 1 }) end
for _, p in ipairs{ {16, 31}, {24, 36}, {12, 35}, {38, 21}, {21, 23} } do H.lit(c, c:ellipse(p[1], p[2], 1.4, 1.2), { "#8f4a1f", "#b8601f", "#d98322", "#e8a02a", "#f5b82e", "#ffd45a" }, { R = 1 }) end
-- rind line
B.ln(c, 9, 29, 29, 37, CH[2]) 
-- mouse
H.lit(c, B.ell(18, 19, 4.4, 3, 0), "stone", { R = 2 })
H.lit(c, B.ell(14, 17, 1.8, 1.8, 0), "petal", { R = 1 })
H.lit(c, B.ell(19, 15, 1.8, 1.8, 0), "petal", { R = 1 })
c:px(14, 19, "#2b1c26") c:px(13, 20, "#d98322")
B.polyline(c, { {22, 21}, {25, 24}, {26, 28} }, "#f5809f")
D.fin()
