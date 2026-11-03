local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-banana: a plump curved banana, five soft ridges, green stalk with a woody cut, dark brown nub at the tip.
-- quirk: a round blue price sticker is stuck on its belly.
local c = D.new("ico-banana")
local BN = { "#8f4a1f", "#c88a22", "#e8a828", "#f8c838", "#ffe060", "#fff4a8" }
local m, T = D.sweep({ {9, 49}, {20, 61}, {50, 48}, {54, 14} }, function(t) return 5.4 * sin(pi * min(1, t * 1.08 + 0.04)) ^ 0.5 + 1 end, 70)
local m2 = m:copy()
D.lit(c, m2, BN, 5, { amb = 0.1 })
-- ridge lines
D.sweep({ {9, 49}, {20, 62}, {49, 47}, {53, 16} }, function() return 0.1 end, 80):each(function(x, y) if m:has(x, y) then D.shift(c, x, y, BN, -1) end end)
-- stalk
c:part(D.sweep({ {52, 16}, {53, 12}, {55, 9}, {57, 6} }, function() return 2.2 end, 20), { hi = "#c4e07a", base = "#7cc35a", shade = "#3f9150", deep = "#24544a" }, { band = 1 })
c:fillMask(c:rect(55, 4, 59, 6), "#51302b")
-- nub
c:part(c:ellipse(8, 49, 3, 3), { hi = "#a87a4a", base = "#74452f", shade = "#51302b", deep = "#2e1a1c" }, { band = 1 })
-- sticker
c:part(c:ellipse(32, 51, 4, 3), "sea", { band = 1 })
c:px(31, 51, CREAM) c:px(32, 51, "#2a4a7a") c:px(33, 51, "#2a4a7a")
for _, p in ipairs{ {17, 52}, {18, 52}, {19, 51} } do c:px(p[1], p[2], "#fff4a8") end
D.fin()
