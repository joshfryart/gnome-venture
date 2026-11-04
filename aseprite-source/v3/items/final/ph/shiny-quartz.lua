local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shiny-quartz (D15 first draft). A cluster of three faceted clear quartz points rising from a grey rock lump, centre prism tall with a pale core, small pink one to the right.
-- quirk: a little trapped bubble ring sits inside the tall crystal.
local c = D.new("shiny-quartz")
D.lit(c, D.ell(32, 54, 24, 5, 0), R.stone, 4)
local function crystal(x0, x1, ytop, yb, apex, Q)
  local xm = floor((x0 + x1) / 2)
  local yk = ytop + floor((yb - ytop) * 0.22)
  c:fillMask(c:poly{ { x0, yk }, { apex, ytop }, { xm, yk } }, Q[4])
  c:fillMask(c:poly{ { xm, yk }, { apex, ytop }, { x1, yk } }, Q[2])
  c:fillMask(c:rect(x0, yk, xm, yb), Q[5])
  c:fillMask(c:rect(xm + 1, yk, x1, yb), Q[3])
  c:fillMask(c:rect(x0, yk, x0, yb), Q[6])
  c:fillMask(c:rect(x1, yk, x1, yb), Q[1])
  c:fillMask(c:rect(xm, yk, xm, yb), Q[6])
end
crystal(8, 20, 28, 54, 12, R.pink)
crystal(44, 56, 32, 54, 52, R.pink)
crystal(25, 41, 7, 54, 31, R.quartz)
-- bubble ring
for _, p in ipairs{ { 31, 28 }, { 32, 27 }, { 33, 28 }, { 32, 29 } } do c:px(p[1], p[2], R.quartz[6]) end
c:px(30, 18, R.quartz[6]) c:px(30, 19, R.quartz[6])
c:sparkle(48, 18)
D.fin()
