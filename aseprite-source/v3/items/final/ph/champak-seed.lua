-- champak-seed (v3 first draft, dB15). quirk: one seed dangles from its silky thread
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("champak-seed")
D.scrap(c, "moss", { w = 9 })
local SEED = { "#5e1a24", "#8c2a2c", "#b43c30", "#d85a38", "#f08050", "#ffb080" }
for _, s in ipairs{ {13, 50, -0.4}, {22, 53, 0.5}, {30, 49, 0.2} } do
  D.seed(c, s[1], s[2], 4, 2.8, s[3], SEED)
  c:px(floor(s[1]) + 2, floor(s[2]) + 1, "#f6ecd6")
end
-- dangling seed on a thread
B.ln(c, 12, 29, 12, 38, "#f6ecd6")
D.seed(c, 12, 41, 2.8, 3.6, 0.0, SEED)
-- sprout
D.stem(c, { {30, 47}, {30, 40}, {33, 34}, {33, 28} }, 0.9, 0.8, "moss")
H.leaf(c, 33, 34, 47, 28, 3.4, "moss", { 3, 6 })
H.leaf(c, 32, 31, 20, 25, 3.4, "moss", { 3, 6 })
H.lit(c, B.ell(33, 24, 2.2, 3.6, 0), "gold", { R = 1.6 })
c:px(32, 22, "#fff4b8")
D.fin()
