-- ico-bouquet first draft (Sonnet). quirk: one loose petal drifting down
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bouquet"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:poly{{20,16},{16,30},{26,28}}, MO, 1.5) D.lit(c:poly{{44,16},{48,30},{38,28}}, MO, 1.5)
local cone = c:poly{{15,30},{49,30},{34,56},{30,56}} D.lit(cone, D.CREAM, 3)
D.ln(c,22,32,31,52,D.CREAM[2]) D.ln(c,40,32,33,52,D.CREAM[2])
local fl = { {22,25,PE}, {42,25,DU}, {32,17,GO} }
for _, f in ipairs(fl) do
  D.lit(B.ell(f[1],f[2],6,6), f[3], 3)
  D.lit(B.ell(f[1],f[2],2,2), f[3] == GO and EM or GO, 1)
end
D.lit(c:poly{{21,37},{43,37},{41,41},{23,41}}, EM, 1.5)
D.lit(c:poly{{31,40},{25,44},{27,47},{32,42}}, EM, 1) D.lit(c:poly{{33,40},{39,44},{37,47},{32,42}}, EM, 1)
D.lit(B.ell(56,34,2.5,1.6,0.8), PE, 1)
D.fin()
