-- nav-together (dC25 first draft, Sonnet). A big sunflower with a seeded brown centre, ring of golden petals, a stem and a leaf. quirk: a tiny bee sits on the bottom petal.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-together") local B, R, HP = D.B, D.R, D.HP
B.ln(c, 32, 34, 32, 60, R.leaf[3]) B.ln(c, 33, 34, 33, 60, R.leaf[4]) B.ln(c, 31, 34, 31, 60, R.leaf[2])
B.lit(c, B.ell(42, 50, 8, 3.5, -.5), R.leaf, 2) B.ln(c, 34, 53, 46, 47, R.leaf[6])
for i = 0, 11 do local a = i * math.pi / 6 + .1
  B.lit(c, B.ell(32 + math.cos(a) * 15, 24 + math.sin(a) * 15, 6.5, 3.4, a), R.sun, 2) end
B.lit(c, c:ellipse(32, 24, 10, 10), R.seedD, 5)
for _, p in ipairs{{28, 20}, {33, 18}, {37, 23}, {30, 25}, {34, 28}, {27, 26}, {32, 22}} do c:px(p[1], p[2], R.seedD[5]) end
B.lit(c, B.ell(32, 41, 3, 2.2, 0), R.sun, 1) c:fillMask(c:rect(31, 41, 33, 41), "#2b1c26") c:px(30, 39, "#fff4d6")
D.fin()
