local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- banana-chips: a small wooden bowl heaped with golden fried banana coins. quirk: one chip has a bite out of it.
local c = D.new("banana-chips")
c:groundShadow(32, 56, 18, 2)
local chips = { {22, 34}, {32, 30}, {42, 34}, {27, 24}, {38, 24}, {32, 17}, {20, 29}, {44, 29} }
for i, p in ipairs(chips) do
  local m = D.ell(p[1], p[2], 6, 5.4, (i % 3 - 1) * 0.3)
  if i == 5 then m:cut(D.ell(p[1] + 5, p[2] - 3, 3, 3, 0)) end
  D.lit(m, D.GRAIN, 3)
  c:fillMask(D.ell(p[1] + (i % 2 == 0 and 1 or -1), p[2], 1.4, 1.2, 0), D.GRAIN[2])
  D.px(p[1] - 3, p[2] - 2, "#fff0a8")
end
local bowl = c:poly{ {10, 34}, {54, 34}, {50, 52}, {42, 55}, {22, 55}, {14, 52} }
D.lit(bowl, D.BRN, 4)
for x = 16, 48, 5 do D.ln(x, 40, x - 1, 52, "#51302b") end
D.ln(11, 35, 53, 35, "#c98a54")
D.fin()
