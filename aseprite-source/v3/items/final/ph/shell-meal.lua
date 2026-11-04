local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shell-meal (D15 first draft). A burlap sack of pale pink ground-shell meal, mouth open with a heap of meal, a cord around the neck and a spiral shell tag.
-- quirk: a whole snail shell hangs from the cord as a label.
local c = D.new("shell-meal")
c:groundShadow(32, 58, 21, 3)
local body = c:poly{ { 14, 56 }, { 11, 42 }, { 16, 31 }, { 25, 26 }, { 39, 26 }, { 48, 31 }, { 53, 42 }, { 50, 56 } }
body:add(D.ell(32, 52, 19, 5, 0))
D.lit(c, body, R.tan, 7)
-- burlap weave
body:each(function(x, y) if (x + y) % 4 == 0 and y > 33 then c:px(x, y, R.tan[3]) end end)
-- mouth and heap
D.lit(c, D.ell(32, 25, 10, 4, 0), R.brown, 3)
local heap = D.ell(32, 22, 8, 5, 0)
heap:cut(c:rect(0, 26, 63, 63))
D.lit(c, heap, R.cream, 5)
for _, p in ipairs{ { 29, 20 }, { 34, 19 }, { 31, 23 } } do c:px(p[1], p[2], D.CREAM) end
c:px(27, 22, R.pink[4]) c:px(36, 22, R.pink[4])
-- cord
D.ln(c, 22, 28, 42, 28, R.brown[1]) D.ln(c, 23, 29, 41, 29, R.brown[3])
D.ln(c, 32, 29, 31, 38, R.brown[3])
-- spiral shell
local sh = D.ell(31, 43, 6, 5, 0.2)
D.lit(c, sh, R.pink, 3)
D.polyline(c, { { 29, 41 }, { 32, 40 }, { 34, 42 }, { 33, 45 }, { 30, 45 }, { 29, 43 }, { 30, 42 } }, R.pink[1], sh)
c:px(28, 40, D.CREAM)
D.fin()
