local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bamboo-shoot: slim cone of overlapping tan sheaths with dark fuzzy edges, a green tip and a few root nubs. quirk: one sheath has peeled off and curls away like a ribbon.
local c = D.new("bamboo-shoot")
c:groundShadow(32, 56, 12, 2)
local rows = { {50, 11}, {40, 9.5}, {30, 8}, {21, 6}, {13, 4} }
for i, r in ipairs(rows) do
  local m = c:poly{ {32 - r[2], r[1] + 8}, {32 - r[2] + 2, r[1] - 3}, {32, r[1] - 8}, {32 + r[2] - 2, r[1] - 3}, {32 + r[2], r[1] + 8} }
  D.lit(m, i % 2 == 0 and D.HUSK or D.TAN, 3.5)
  for x = 32 - floor(r[2]), 32 + floor(r[2]), 3 do D.px(x, r[1] + 3, "#51302b") end
end
D.lf(32, 9, 2.4, 6, 0, D.LEAF)
for i = 0, 3 do D.px(24 + i * 4, 57, "#5e4630") end
D.ln(45, 30, 50, 26, "#8e7242") D.ln(50, 26, 53, 28, "#b8985a") D.ln(46, 31, 51, 27, "#d8bd7c")
D.fin()
