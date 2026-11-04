-- nav-arranging (dC25 first draft, Sonnet). Terracotta pot holding a pink, an ember and a violet bloom. quirk: a tiny bee sits on the middle flower.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC25.lua")
local c = D.new("nav-arranging") local B, R, HP = D.B, D.R, D.HP
D.shadow(c, 32, 59, 15, 2)
B.ln(c, 20, 27, 27, 41, R.leaf[3]) B.ln(c, 32, 22, 32, 41, R.leaf[3]) B.ln(c, 44, 27, 37, 41, R.leaf[3])
B.lit(c, B.ell(24, 36, 4, 2, -.7), R.leaf, 1.4)
local function bloom(x, y, ramp)
  for i = 0, 5 do local a = i * math.pi / 3 B.lit(c, B.ell(x + math.cos(a) * 4, y + math.sin(a) * 4, 3, 2.2, a), ramp, 1.5) end
  B.lit(c, c:ellipse(x, y, 2.5, 2.5), R.gold, 1.5)
end
bloom(19, 22, R.petal) bloom(32, 14, R.red) bloom(45, 22, R.dusk)
B.lit(c, c:poly{{17, 44}, {47, 44}, {43, 58}, {21, 58}}, R.gold, 4)
B.lit(c, c:rrect(15, 39, 49, 45, 2), R.sun, 2)
D.line(c, {{22, 53}, {42, 53}}, 1, R.gold[1])
B.lit(c, B.ell(37, 12, 1.8, 1.4, 0), R.sun, 1) c:px(37, 12, "#2b1c26") c:px(35, 10, "#fff4d6")
D.fin()
