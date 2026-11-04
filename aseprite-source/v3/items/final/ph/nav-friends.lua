-- nav-friends (dC25 first draft, Sonnet). Two gnome heads side by side, green hat and violet hat, tips bent together. quirk: a tiny pink heart floats between the hat tips.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-friends") local B, R, HP = D.B, D.R, D.HP
local function gnome(cx, hatR, dir)
  B.lit(c, c:poly{{cx - 3, 40}, {cx + 11, 40}, {cx + 4, 58}}, R.beard, 3)
  B.lit(c, c:poly{{cx - 11, 28}, {cx + 11, 28}, {cx + dir * 4, 7}, {cx + dir * 8, 8}, {cx + dir * 6, 12}}, hatR, 4)
  B.lit(c, c:ellipse(cx, 33, 8, 6), R.skin, 4)
  B.lit(c, c:rect(cx - 10, 27, cx + 10, 30), hatR, 1.5)
  B.lit(c, c:ellipse(cx, 35, 3, 2), R.skin, 1.5) c:px(cx - 1, 34, R.cream[6])
  c:eyeSmall(cx - 6, 31) c:eyeSmall(cx + 4, 31)
  B.lit(c, c:ellipse(cx, 39, 5, 2.5), R.beard, 1.5)
end
gnome(17, R.leaf, 1) gnome(47, R.dusk, -1)
c:fillMask(c:poly{{30, 5}, {35, 5}, {35, 8}, {32.5, 11}, {30, 8}}, R.petal[4])
D.fin()
