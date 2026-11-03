local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-leafy-green: a ruffled lettuce head of overlapping leaves. quirk: a caterpillar has nibbled a notch and sits in it.
local c = D.new("ico-leafy-green")
local ls = {
  { 18, 36, 12, 15, "moss" }, { 46, 36, 12, 15, "moss" }, { 32, 44, 16, 11, "moss" },
  { 24, 28, 11, 14, D.GREEN }, { 40, 28, 11, 14, D.GREEN }, { 32, 24, 11, 15, "moss" } }
for _, l in ipairs(ls) do
  local m = D.ell(l[1], l[2], l[3], l[4])
  D.lit(m, l[5], 4)
  D.ln(l[1], l[2] + l[4] - 3, l[1], l[2] - l[4] + 4, l[5] == "moss" and D.rp("moss")[6] or D.GREEN[5], m)
end
for _, r in ipairs{ {26,22,22,30}, {38,22,42,30} } do D.ln(r[1], r[2], r[3], r[4], D.GREEN[2]) end
D.lit(c:poly{{24,50},{40,50},{36,56},{28,56}}, D.CREAM, 1)
D.lit(D.ell(46, 21, 3, 2.4), D.GREEN, 1.5) D.lit(D.ell(50, 22, 2.4, 2), D.GREEN, 1)
D.px(45, 20, INK) D.px(44, 22, D.RED[4])
D.fin()
