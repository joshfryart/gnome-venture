local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- sea-salt (D15 first draft). A small round stone dish heaped with chunky blue-white salt crystals, a few loose cubes in front.
-- quirk: a tiny seagull footprint pressed into the salt.
local c = D.new("sea-salt")
c:groundShadow(32, 56, 22, 3)
D.lit(c, D.ell(32, 47, 22, 9, 0), R.stone, 5)
D.lit(c, D.ell(32, 45, 18, 6.5, 0), R.iron, 4)
local mound = c:poly{ { 15, 45 }, { 21, 34 }, { 28, 24 }, { 36, 22 }, { 43, 31 }, { 50, 45 } }
mound:add(D.ell(32, 44, 17, 5, 0))
D.lit(c, mound, R.salt, 7)
-- cubes
local function cube(x, y, s)
  c:fillMask(c:rect(x, y, x + s, y + s), R.salt[4])
  c:fillMask(c:rect(x, y, x + s, y), R.salt[6])
  c:fillMask(c:rect(x + s, y + 1, x + s, y + s), R.salt[2])
  c:fillMask(c:rect(x + 1, y + s, x + s, y + s), R.salt[2])
  c:px(x + 1, y + 1, R.salt[5])
end
for _, q in ipairs{ { 28, 28, 3 }, { 36, 31, 3 }, { 22, 38, 3 }, { 42, 38, 3 }, { 32, 36, 4 }, { 18, 44, 3 }, { 46, 44, 3 }, { 26, 44, 4 }, { 37, 45, 4 } } do cube(q[1], q[2], q[3]) end
-- gull footprint
for _, p in ipairs{ { 33, 31 }, { 33, 30 }, { 32, 30 }, { 34, 30 }, { 33, 29 } } do c:px(p[1], p[2], R.salt[2]) end
c:sparkle(44, 24)
D.fin()
