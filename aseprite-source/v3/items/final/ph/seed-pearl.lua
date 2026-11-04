local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- seed-pearl (D15 first draft). An open ribbed scallop shell cradling one big pearl and two tiny seed pearls.
-- quirk: a green seedling sprouts out of the shell's rim.
local c = D.new("seed-pearl")
-- seedling behind
D.ln(c, 47, 29, 48, 14, "#78bd5c")
D.lit(c, D.ell(43, 15, 4, 2.2, -0.5), R.fresh, 1.8)
D.lit(c, D.ell(52, 12, 4, 2.2, 0.5), R.fresh, 1.8)
-- shell
local shell = D.ell(32, 40, 22, 16, 0)
D.lit(c, shell, R.pink, 6)
for i = -4, 4 do
  D.ln(c, 32 + i * 2, 54, 32 + i * 5, 28, i % 2 == 0 and R.pink[1] or R.pink[5], shell)
end
D.lit(c, D.ell(32, 41, 16, 10, 0), R.cream, 5)
-- hinge
D.lit(c, c:rect(25, 53, 39, 57), R.pink, 2)
-- pearls
D.lit(c, D.ell(24, 45, 2.8, 2.8, 0), R.salt, 2.5)
D.lit(c, D.ell(41, 46, 2.8, 2.8, 0), R.salt, 2.5)
D.lit(c, D.ell(32, 39, 6, 6, 0), R.salt, 5)
c:px(29, 36, D.CREAM) c:px(30, 36, D.CREAM) c:px(29, 37, D.CREAM)
c:px(34, 43, "#f5809f") c:px(35, 42, "#8bc4ea")
D.fin()
