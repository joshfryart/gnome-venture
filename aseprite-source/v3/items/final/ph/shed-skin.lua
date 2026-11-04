local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shed-skin (D15 first draft). A papery, pale olive snake slough in a lazy S, diamond scale pattern, head cap with an empty eye window, ragged tail tip.
-- quirk: a small tear in the middle of the skin shows the ground through it.
local c = D.new("shed-skin")
local m, T = D.sweep({ { 12, 44 }, { 28, 62 }, { 26, 20 }, { 52, 18 } }, function(t) return 4.4 - 3.0 * t ^ 1.3 end, 80)
m:add(D.ell(11, 44, 5.4, 4.4, -0.3))
m:cut(D.ell(31, 38, 1.6, 1.6, 0))
D.lit(c, m, R.skin, 2.8)
m:each(function(x, y)
  if (x + (y % 2) * 2) % 4 == 0 then c:px(x, y, R.skin[2]) end
  if (x + 2 + (y % 2) * 2) % 8 == 0 and y % 2 == 1 then c:px(x, y, R.skin[6]) end
end)
-- head cap and eye window
D.ln(c, 14, 40, 14, 47, R.skin[1])
D.lit(c, D.ell(9, 43, 1.6, 1.4, 0), { "#2b1c26", "#2b1c26", "#6b6a48", "#8f8e62", "#b5b484", "#d2d1a6" }, 1)
c:px(8, 42, D.CREAM)
-- ragged tail
c:px(55, 17, R.skin[1]) c:px(56, 18, R.skin[2])
D.fin()
