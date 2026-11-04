-- moth-wing: one dusty brown moth forewing with a cream eyespot, zigzag band, scalloped fringe and radiating veins. quirk: a puff of wing powder dusts off its edge.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("moth-wing")
local W = D.R("#e8c898", "#b48a60", "#7e5a44", "#46302e")
local wing = c:poly{ {10,50}, {14,28}, {24,13}, {42,9}, {55,17}, {52,31}, {44,43}, {30,52}, {18,54} }
-- scallops on the trailing edge
for _, p in ipairs{ {55,17,3}, {52,28,3}, {46,38,3}, {38,46,3}, {28,51,3} } do wing:add(c:ellipse(p[1] - 1, p[2], p[3] - 1, p[3] - 1)) end
B.lit(c, wing, W, 8, { amb = .12 })
for i = 0, 7 do
  local a = -1.9 + i * 0.28
  B.ln(c, 12, 50, 12 + cos(a) * 52, 50 + sin(a) * 52, i % 2 == 0 and W.shade or W.hi, wing)
end
-- band
for x = 28, 52 do local y = 36 - floor(abs((x % 6) - 3)) - floor((x - 28) * .36) if wing:has(x, y) then c:px(x, y, W.deep) c:px(x, y + 1, W.hi) end end
-- eyespot
local e = c:ellipse(37, 25, 5, 5)
c:fillMask(e, "#46302e") c:fillMask(e:shrink(1), "#f5b82e") c:fillMask(e:shrink(2), "#2b1c26")
c:px(35, 23, "#fff4d6") c:px(36, 23, "#fff4d6")
-- fringe flecks
for _, p in ipairs{ {53,20},{51,30},{44,42},{36,49},{26,52} } do c:px(p[1], p[2], "#fff4d6") end
-- powder puff
for _, p in ipairs{ {57,10},{59,8},{58,12},{56,7},{60,11},{61,6} } do c:px(p[1], p[2], p[1] % 2 == 0 and "#e8c898" or "#fff4d6") end
D.fin()
