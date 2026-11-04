-- nav-garden (dC25 first draft, Sonnet). A picket fence with a seedling in a dirt mound in front. quirk: a small snail rides the mound.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-garden") local B, R, HP = D.B, D.R, D.HP
for i = 0, 4 do
  local x = 6 + i * 11
  B.lit(c, c:poly{{x, 26}, {x + 4, 18}, {x + 8, 26}, {x + 8, 52}, {x, 52}}, "wood", 3)
end
D.rod(c, {{6, 32}, {58, 32}}, 3, "wood", 1.5) D.rod(c, {{6, 45}, {58, 45}}, 3, "wood", 1.5)
B.lit(c, c:ellipse(32, 54, 20, 6), R.brown, 5)
B.ln(c, 32, 52, 32, 36, R.leaf[3]) B.ln(c, 33, 52, 33, 38, R.leaf[4])
B.lit(c, B.ell(24, 36, 6, 3, -.5), R.sprout, 2) B.lit(c, B.ell(41, 34, 6, 3, .5), R.sprout, 2)
B.ln(c, 20, 37, 28, 36, R.sprout[6]) 
B.lit(c, c:ellipse(16, 51, 3, 3), R.sun, 1.6) c:fillMask(c:rect(18, 53, 25, 54), R.skin[3])
B.ln(c, 21, 52, 22, 49, R.skin[3])
D.fin()
