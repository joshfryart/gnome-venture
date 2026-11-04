local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- sea-grapes (D15 first draft). One big round veined leathery leaf over a hanging raceme of nine round grapes that ripen from green (top) to purple (bottom).
-- quirk: a drop of sea water hangs from the lowest grape.
local c = D.new("sea-grapes")
local lm = D.ell(21, 19, 13, 10, -0.35)
D.lit(c, lm, R.leaf, 5)
D.ln(c, 10, 28, 30, 11, R.leaf[6], lm)
for _, v in ipairs{ { 15, 24, 12, 31 }, { 19, 20, 17, 30 }, { 23, 16, 23, 28 }, { 15, 22, 11, 19 }, { 22, 18, 27, 24 } } do
  D.ln(c, v[1], v[2], v[3], v[4], R.leaf[5], lm)
end
D.ln(c, 21, 19, 33, 30, "#7a5a38")
D.ln(c, 34, 24, 34, 50, "#7a5a38")
local g = {
  { 30, 31, R.fresh }, { 38, 32, R.fresh }, { 26, 39, R.leaf }, { 34, 38, R.fresh }, { 42, 39, R.purple },
  { 30, 46, R.purple }, { 38, 46, R.purple }, { 34, 54, R.purple },
}
for _, b in ipairs(g) do
  D.lit(c, D.ell(b[1], b[2], 3.7, 3.7, 0), b[3], 3.2)
  c:px(b[1] - 1, b[2] - 2, D.CREAM)
end
-- sea-water drop
for _, p in ipairs{ { 34, 59 }, { 33, 60 }, { 34, 60 }, { 35, 60 }, { 34, 61 } } do c:px(p[1], p[2], p[2] == 59 and "#b6f0e0" or "#5fc4c8") end
c:px(33, 60, "#b6f0e0")
D.fin()
