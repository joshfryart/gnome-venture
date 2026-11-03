local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-lightning: bold gold zig-zag bolt. quirk: little spark ticks and a tiny cloud tuft at its top.
local c = D.new("ico-lightning")
D.lit(D.ell(24, 10, 8, 5):add(D.ell(34, 8, 8, 5)):add(D.ell(42, 11, 6, 4)), D.STEEL, 3)
local b = c:poly{{36,12},{16,36},{28,36},{22,60},{48,28},{35,28},{44,12}}
D.lit(b, D.GOLD, 5)
D.fill(c:rect(36, 14, 37, 20), D.GOLD[6]) D.fill(c:rect(35, 16, 36, 22), D.GOLD[6])
D.ln(50, 40, 56, 44, D.GOLD[5]) D.ln(52, 34, 58, 34, D.GOLD[5]) D.ln(10, 46, 6, 52, D.GOLD[5])
D.fin()
