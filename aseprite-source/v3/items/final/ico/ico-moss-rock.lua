-- ico-moss-rock first draft (Sonnet). quirk: a tiny pink flower sprouts from the moss on top
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-moss-rock")
c:groundShadow(32, 56, 22, 3)
local rock = c:poly{ {10, 52}, {9, 40}, {16, 28}, {26, 20}, {38, 19}, {49, 26}, {55, 38}, {54, 52} }
rock:add(D.ell(32, 40, 22, 13))
rock:cut(c:rect(0, 53, 63, 63))
D.lit(rock, "stone", 9, { amb = .1 })
-- cracks
D.ln(24, 52, 26, 44, "#444663") D.ln(26, 44, 24, 40, "#444663")
D.ln(44, 50, 42, 43, "#5a5c78")
-- moss cap with dripping edge
local moss = HP.mask()
rock:each(function(x, y)
  local lim = 31 + 4 * sin(x * 0.55) + 3 * cos(x * 0.31 + 1)
  if y <= lim then moss:set(x, y) end
end)
D.lit(moss, "moss", 5, { amb = .12 })
for _, p in ipairs{ {18, 34}, {19, 38}, {40, 36}, {45, 38}, {30, 38} } do
  if rock:has(p[1], p[2]) then D.fill(c:rect(p[1], p[2] - 2, p[1] + 1, p[2]), "#3f9150") end
end
for _, p in ipairs{ {22, 27}, {30, 24}, {42, 28}, {36, 30} } do c:px(p[1], p[2], "#c4e07a") end
-- flower
D.ln(34, 22, 34, 14, "#3f9150")
D.fill(c:rect(35, 18, 37, 19), "#3f9150")
for _, p in ipairs{ {-2,-1},{2,-1},{0,-3},{0,1} } do D.fill(c:rect(34 + p[1] - 1, 12 + p[2], 34 + p[1] + 0, 12 + p[2] + 1), "#f5809f") end
D.fill(c:rect(33, 11, 35, 13), "#f5809f")
D.fill(c:rect(34, 12, 34, 12), "#ffe38a")
D.fin()
