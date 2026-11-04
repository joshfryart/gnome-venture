-- rice-and-beans (final draft D12, Sonnet). Blue-banded china bowl heaped with fluffy white rice and glossy red kidney
-- beans, a parsley sprig on top. quirk: one runaway bean has rolled out and sits beside the bowl.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rice-and-beans")
D.shadow(c, 30, 58, 22, 3)
local bowl = c:ellipse(30, 42, 20, 14):clip(c:rect(0, 37, 63, 63))
bowl:add(c:ellipse(30, 37, 20, 5))
local bi = D.lit(c, bowl, D.R.china, 8, { wrap = 0.25 })
D.recolor(c, bowl, bi, D.R.glass, function(x, y) return y >= 43 and y <= 44 end)
D.recolor(c, bowl, bi, { "#2a295f", "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0", "#e0d0f8" }, function(x, y) return y == 41 or (y == 47 and false) end)
-- foot
local foot = c:rrect(21, 54, 39, 57, 1)
D.lit(c, foot, D.R.china, 1.5, {})
-- rice mound
local mound = c:ellipse(30, 32, 17, 9):clip(c:rect(0, 0, 63, 38))
D.lit(c, mound, D.R.cream, 6, { wrap = 0.35 })
D.scatter(mound, 30, 5, function(x, y) c:px(x, y, "#fff4d6") c:px(x + 1, y, "#b58d70") end)
-- rim over mound base
c:fillMask(c:ellipse(30, 38, 19, 3):cut(c:ellipse(30, 38, 0, 0)), "#2a295f")
for x = 12, 48 do c:px(x, 38, "#e6eef6") end
-- beans
local BN = { "#3a1018", "#6e2038", "#a02a3c", "#c8403c", "#e86a50", "#ffa07a" }
for _, q in ipairs{ {22,31,0.4},{34,28,-0.3},{29,34,0.2},{41,33,-0.5},{19,35,-0.2},{37,35,0.4},{27,26,0.1} } do
  local m = B.ell(q[1], q[2], 2.6, 1.8, q[3]) B.lit(c, m, BN, 1.5) c:px(q[1] - 1, q[2] - 1, "#ffd0b0")
end
-- parsley
for _, q in ipairs{ {30,22,2.2,1.6,-0.3},{27,24,2.2,1.5,0.4},{33,24,2.2,1.5,-0.5} } do B.lit(c, B.ell(q[1], q[2], q[3], q[4], q[5]), D.R.leaf, 1.4) end
D.ln(c, 30, 23, 30, 27, "#6ab455")
-- runaway bean
local rb = B.ell(53, 54, 3, 2.1, 0.3) c:fillMask(B.ell(54, 55, 3.2, 2.2, 0.3), "#7a2a30") B.lit(c, rb, BN, 1.8) c:px(52, 53, "#ffd0b0")
-- steam
D.curl(c, { {26,17},{25,14},{27,12},{26,9} }, "#e4f6ff") D.curl(c, { {35,18},{36,15},{34,12} }, "#b9e2f5")
D.fin()
