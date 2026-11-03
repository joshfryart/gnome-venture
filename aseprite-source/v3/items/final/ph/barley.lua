local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- barley: two slim golden stalks, each with a bearded ear of paired kernels and long whisker-like awns, one grass leaf. quirk: one awn has curled into a spiral.
local c = D.new("barley")
D.ln(30, 56, 28, 24, "#9aa84a") D.ln(31, 56, 29, 24, "#6a8a3e") D.ln(40, 56, 42, 28, "#9aa84a") D.ln(41, 56, 43, 28, "#6a8a3e")
D.lf(36, 46, 1.6, 9, 0.45, D.LEAF2)
for _, E in ipairs{ {29, 24, -0.1}, {42, 28, 0.15} } do
  for i = 0, 5 do
    local y = E[2] - i * 3.4
    local x = E[1] + E[3] * i * 2
    D.lit(D.ell(x - 1.6, y, 1.7, 2.2, -0.4), D.GRAIN, 1.4) D.lit(D.ell(x + 1.8, y, 1.7, 2.2, 0.4), D.GRAIN, 1.4)
    D.ln(x - 2, y - 1, x - 7 - i, y - 11 - i * 0.7, D.GRAIN[3]) D.ln(x + 2, y - 1, x + 7 + i, y - 11 - i * 0.7, D.GRAIN[4])
  end
end
for i = 0, 6 do D.px(14 + floor(math.cos(i) * 2), 8 + i % 3, D.GRAIN[3]) end
D.fin()
