local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-ladder: two wooden rails and five rungs. quirk: a little green vine climbs it and a leaf sits on the top rung.
local c = D.new("ico-ladder")
D.lit(D.seg({{19,57},{23,6}}, 5), "wood", 2)
D.lit(D.seg({{43,57},{47,6}}, 5), "wood", 2)
for i, y in ipairs{14, 25, 36, 47} do
  local x0, x1 = 21 + (57 - y) * -0.078 + 0, 45 + (57 - y) * -0.078
  D.lit(c:rect(floor(x0) + 2, y, floor(x1) - 2, y + 3), "wood", 1.5)
  D.px(floor(x0) + 5, y + 1, D.WICK and D.BRN[1] or INK)
end
D.ln(21, 54, 23, 40, D.GREEN[2]) D.ln(23, 40, 27, 36, D.GREEN[2]) D.ln(27, 36, 24, 26, D.GREEN[2])
D.leaf(24, 26, 31, 20, 3, "moss", {3}) D.leaf(23, 41, 17, 36, 3, "moss", {3})
D.px(24, 6, D.BRN[6])
D.fin()
