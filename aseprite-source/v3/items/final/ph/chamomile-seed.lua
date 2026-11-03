-- chamomile-seed (v3 first draft, dB15). quirk: a tiny daisy bud already opens on the sprout
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("chamomile-seed")
D.scrap(c, "moss")
local SEED = { "#5c4a2a", "#806a3c", "#a48c52", "#c4aa6a", "#ddc888", "#f0e4ac" }
for _, s in ipairs{ {12, 52, 0.4}, {18, 54, -0.3}, {24, 50, 0.9}, {30, 54, 0.1}, {36, 51, -0.7}, {44, 54, 0.6} } do
  D.seed(c, s[1], s[2], 2.3, 1.2, s[3], SEED)
end
D.stem(c, { {36, 49}, {36, 42}, {34, 34}, {35, 24} }, 0.8, 0.7, "moss")
local G = "#58a84e"
-- feathery leaves: thin forked threads
for _, L in ipairs{ {36, 42, 24, 38, 20, 33}, {36, 42, 48, 38, 52, 33}, {35, 34, 26, 30, 22, 25}, {35, 34, 44, 30, 48, 25} } do
  B.ln(c, L[1], L[2], L[3], L[4], "#3f8f4c") B.ln(c, L[3], L[4], L[5], L[6], "#62ad55")
  B.ln(c, L[3], L[4] - 1, L[3] + (L[5] - L[3]) // 2, L[6] + 4, "#93cb68") B.ln(c, L[3], L[4], L[5] + 2, L[6] + 2, "#93cb68")
end
for a = 0, 7 do local ang = a * pi / 4 H.lit(c, B.ell(35 + cos(ang) * 4, 19 + sin(ang) * 4, 2, 1.4, ang), { "#9a98b0", "#c4c2d0", "#e2e0e6", "#f4f2f0", "#fffaf0", "#fff8e8" }, { R = 1 }) end
H.lit(c, c:ellipse(35, 19, 2, 2), "gold", { R = 1.5 })
D.fin()
