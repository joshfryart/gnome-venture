-- ceibo-seed (v3 first draft, dB15). quirk: a red ceibo flower bud tops the sprout
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("ceibo-seed")
D.scrap(c, "moss")
local COT = { "#6e6a7a", "#a8a4b4", "#d4d0d8", "#ece8e4", "#f8f4ea", "#fffaf0" }
local SEED = { "#2a1618", "#43261f", "#5e3a2a", "#7c5236", "#9c6c44", "#c08c5c" }
local S = { {15, 49}, {26, 53}, {36, 48} }
for _, s in ipairs(S) do
  H.lit(c, B.ell(s[1] - 2, s[2] - 2, 5, 3.6, -0.6), COT, { R = 2 })
  H.lit(c, B.ell(s[1] + 3, s[2] - 2, 4, 3, 0.5), COT, { R = 2 })
end
for _, s in ipairs(S) do D.seed(c, s[1], s[2], 2.8, 2.2, 0.4, SEED) end
D.stem(c, { {36, 46}, {35, 38}, {37, 32}, {36, 26} }, 1, 0.9, "moss")
H.leaf(c, 36, 28, 22, 24, 3, "moss", { 3, 7 })
H.leaf(c, 36, 28, 50, 24, 3, "moss", { 3, 7 })
H.leaf(c, 36, 26, 36, 12, 3, "moss", { 3, 6 })
H.lit(c, B.ell(36, 25, 2.2, 2.6, 0), "ember", { R = 1.5 })
c:px(35, 24, "#ffc4a8")
D.fin()
