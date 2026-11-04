-- rock-dust (final draft D12, Sonnet). A stone mortar heaped with fine pale lilac rock dust, a stone pestle leaning in
-- the bowl, a few grains scattered at the foot. quirk: a puff of dust floats up like a tiny cloud with a sparkle.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rock-dust")
D.shadow(c, 28, 58, 22, 3)
local bowl = c:ellipse(28, 44, 21, 13):clip(c:rect(0, 40, 63, 63))
bowl:add(c:ellipse(28, 40, 21, 6))
local bi = D.lit(c, bowl, D.R.stone, 9, { wrap = 0.25 })
-- spout lip at left
c:fillMask(c:poly{ {6,38},{10,36},{10,42} }, D.R.stone[4]) c:px(6, 38, D.R.stone[3])
-- foot
D.lit(c, c:rrect(18, 54, 38, 57, 1), D.R.stone, 1.5, {})
-- dark bowl interior then dust heap
local DU = { "#5a566c", "#7a7690", "#9a96b0", "#bab6cc", "#d6d2e0", "#f0ecf6" }
local heap = c:ellipse(28, 36, 16, 9):clip(c:rect(0, 0, 63, 42))
D.lit(c, heap, DU, 6, { wrap = 0.35 })
D.scatter(heap, 24, 12, function(x, y) c:px(x, y, DU[6]) end)
for x = 8, 48 do c:px(x, 41, "#35364f") end
-- pestle
local pm = D.stalk(c, 50, 14, 36, 36, function(t) return 3.4 - 1.2 * t end, D.R.stone, { -0.3 })
B.lit(c, B.ell(51, 13, 4.4, 4, 0), D.R.stone, 3)
c:px(49, 11, "#fff4d6")
-- loose grains
for _, q in ipairs{ {50,52},{54,55},{47,57} } do c:px(q[1], q[2], DU[4]) c:px(q[1] + 1, q[2], DU[2]) end
-- dust puff
local pf = HP.mask()
pf:add(c:ellipse(14, 24, 4, 3)):add(c:ellipse(19, 21, 4, 3.5)):add(c:ellipse(10, 27, 3, 2.4)):add(c:ellipse(18, 27, 4, 2.6))
D.lit(c, pf, DU, 3, { wrap = 0.35 })
c:sparkle(24, 14)
D.fin()
