-- ico-paw first draft (Sonnet). quirk: a tiny plaster is stuck on one toe
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-paw")
local BR = { "#2e1a20", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
local PD = { "#7d2c5e", "#a83e6e", "#c94f84", "#f5809f", "#ff9ab8", "#ffc4d8" }
-- main pad (heart-ish trapezoid)
local main = D.ell(32, 43, 14, 11):add(D.ell(22, 38, 7, 6)):add(D.ell(42, 38, 7, 6)):add(c:rect(20, 44, 44, 52))
main:cut(c:rect(0, 54, 63, 63))
D.lit(main, BR, 8)
D.lit(D.ell(32, 46, 9, 6):add(D.ell(32, 42, 5, 4)), PD, 4)
-- toes
local toes = { {13, 30, 4.5, 6, -0.4}, {25, 20, 4.5, 6.5, -0.12}, {39, 20, 4.5, 6.5, 0.12}, {51, 30, 4.5, 6, 0.4} }
for i, t in ipairs(toes) do
  D.lit(D.ell(t[1], t[2], t[3] + 1, t[4] + 1, t[5]), BR, 4)
  D.lit(D.ell(t[1], t[2] + 1, t[3] - 1, t[4] - 2, t[5]), PD, 2)
end
-- plaster on the left toe
local pl = c:line({ {7, 32}, {19, 27} }, 5)
D.fill(pl, "#f0b98d") D.fill(c:line({ {7, 31}, {19, 26} }, 2), "#ffe0bd") D.fill(c:line({ {8, 34}, {19, 29} }, 1), "#c98462")
D.fill(c:rect(12, 29, 14, 31), "#fff0cc")
c:px(12, 29, "#c98462") c:px(14, 31, "#c98462") c:px(13, 30, "#c98462")
c:px(30, 40, "#ffc4d8") c:px(31, 40, "#ffc4d8")
D.fin()
