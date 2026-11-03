-- cherry-seed (v3 first draft, dB15). quirk: an empty cherry stem still clings to one pit
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cherry-seed")
D.scrap(c, "moss", { w = 8 })
local PIT = { "#6a4a2a", "#9a7040", "#c49a5c", "#dcb878", "#eed39a", "#fdecc0" }
for _, s in ipairs{ {13, 51, 0.4}, {24, 54, -0.2} } do
  D.seed(c, s[1], s[2], 4, 3, s[3], PIT)
  B.ln(c, s[1] - 2, s[2] - 1, s[1] + 2, s[2] + 1, PIT[2])
end
B.polyline(c, { {10, 49}, {8, 45}, {10, 41} }, "#6a7a38")
c:px(10, 41, "#b52e3f")
D.seed(c, 36, 50, 4.4, 3.2, -0.5, PIT)
B.ln(c, 34, 52, 38, 48, PIT[2])
D.stem(c, { {38, 48}, {40, 40}, {38, 32}, {40, 24} }, 0.9, 0.8, "wood")
for _, L in ipairs{ {39, 34, 26, 30, 3.6}, {40, 32, 54, 26, 3.6}, {40, 24, 36, 12, 3.2} } do
  local m = H.leaf(c, L[1], L[2], L[3], L[4], L[5], "moss", { 3, 6 })
  m:edge():each(function(x, y) if (x + y) % 3 == 0 and m:has(x + 1, y) then c:px(x, y, "#3f9150") end end)
end
D.fin()
