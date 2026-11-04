-- cherry (v3 first draft, dB15). quirk: one cherry has a small bite out of it
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cherry")
local CR = { "#4a1428", "#7d1f38", "#b52e3f", "#d83c44", "#f0585a", "#ff9a8c" }
local ST = { "#3f5a2a", "#5a7a34", "#7c9a44" }
local s1 = { {30, 10}, {27, 18}, {22, 28}, {21, 36} }
local s2 = { {30, 10}, {34, 18}, {40, 28}, {41, 38} }
for _, s in ipairs{ s1, s2 } do D.bline(c, s, "#6a7a38") D.bline(c, s, "#8ea04c", nil, 1, 0) end
H.lit(c, B.ell(30, 10, 2, 1.4, 0), "wood", { R = 1 })
-- leaf
H.leaf(c, 31, 10, 50, 5, 4.2, "moss", { 4, 8, 12 })
local m1 = B.ell(21, 43, 9, 9, 0)
H.lit(c, m1, CR, { R = 5 })
c:px(17, 38, "#ffd4cc") c:px(18, 38, "#ffd4cc") c:px(17, 39, "#ffc0b4")
local m2 = B.ell(41, 46, 9, 9, 0):cut(B.ell(47, 40, 3.6, 3.6, 0))
H.lit(c, m2, CR, { R = 5 })
B.ln(c, 37, 40, 37, 40, "#ffd4cc")
c:px(37, 41, "#ffd4cc") c:px(38, 41, "#ffd4cc")
-- bitten flesh rim
B.ell(47, 40, 3.6, 3.6, 0):each(function(x, y) if m2:has(x - 1, y) or m2:has(x, y + 1) then if not m2:has(x, y) then end end end)
for _, p in ipairs{ {44, 41}, {45, 43}, {47, 44}, {49, 43}, {50, 41} } do if m2:has(p[1], p[2]) then c:px(p[1], p[2], "#ffe0b8") end end
c:px(43, 39, "#4a1428")
-- dimple
c:px(21, 35, "#4a1428") c:px(41, 38, "#4a1428")
D.fin()
