-- chaconia-seed (v3 first draft, dB15). quirk: a scarlet bract star crowns the tiny sprout
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("chaconia-seed")
D.scrap(c, "moss")
local SEED = { "#1c1420", "#2e2030", "#46303c", "#624454", "#84606c", "#aa8890" }
for _, s in ipairs{ {14, 50, 0.7}, {23, 53, -0.3}, {33, 49, 0.2} } do
  D.seed(c, s[1], s[2], 3.4, 2.2, s[3], SEED)
  B.ln(c, s[1] - 1, s[2], s[1] + 1, s[2], SEED[2])
end
D.stem(c, { {33, 47}, {32, 40}, {35, 34}, {34, 26} }, 0.9, 0.8, "moss")
H.leaf(c, 33, 38, 22, 34, 3, "moss", { 3 })
H.leaf(c, 34, 36, 46, 32, 3, "moss", { 3 })
for _, a in ipairs{ 0, 1, 2, 3, 4 } do
  local ang = a * 2 * pi / 5 - pi / 2
  local ex, ey = 34 + cos(ang) * 6, 20 + sin(ang) * 6
  H.leaf(c, 34, 20, floor(ex + .5), floor(ey + .5), 2.2, "ember", {})
end
H.lit(c, c:ellipse(34, 20, 1, 1), "gold", { R = 1 })
D.fin()
