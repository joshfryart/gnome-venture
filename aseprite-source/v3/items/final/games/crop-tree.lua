local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- crop-tree: tall pear with a long neck, lit green-yellow skin, freckles, curved stem and leaf.
-- quirk: a small blue butterfly rests on the pear's shoulder.
local c = D.new("crop-tree")
local PEAR = { "#4d5a1c", "#7f8f2a", "#a6b834", "#c8d444", "#e0e868", "#f6f5a8" }
c:groundShadow(32, 58, 13, 2)
local m = c:ellipse(32, 44, 13, 12):add(c:ellipse(32, 29, 8, 11)):add(c:ellipse(32, 36, 11, 8))
D.lit(c, m, PEAR, 7, { amb = 0.06 })
m:edge():each(function(x, y) if x > 38 and y > 50 then c:px(x, y, "#5aa090") end end)
for _, p in ipairs{ {26, 42}, {38, 36}, {28, 50}, {36, 47}, {33, 33} } do D.shift(c, p[1], p[2], PEAR, -2) end
for _, p in ipairs{ {24, 40}, {24, 41}, {25, 39}, {28, 24}, {28, 25} } do c:px(p[1], p[2], "#fbfbc8") end
c:part(c:line({ {32, 20}, {32, 14}, {36, 9} }, 2), "wood", { band = 1 })
D.leaf(c, 35, 14, 51, 9, 5, "moss", { 4, 8 })
-- butterfly on the shoulder (right)
local bf = {
  "..b....b..",
  ".bBb..bBb.",
  "bBhBbbBhBb",
  ".bBBKKBBb.",
  "..bbKKbb..",
}
local map = { b = "#3a86b0", B = "#5fc4c8", h = "#b6f0e0", K = INK }
c:paint(bf, 36, 27, map)
D.fin()
