-- ico-boat first draft (Sonnet). quirk: a stitched patch on the mainsail
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-boat"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:rect(30,10,32,43), W, 1)
D.lit(c:poly{{34,14},{34,40},{52,40}}, D.CREAM, 2.5, {amb=.2})
D.lit(c:poly{{28,17},{28,40},{12,40}}, GO, 2.5, {amb=.2})
D.lit(c:poly{{32,9},{42,12},{32,15}}, D.RED, 1)
D.lit(c:rect(39,34,44,38), D.RED, 1) c:stitch({{38,33},{45,33},{45,39},{38,39},{38,33}})
D.lit(c:poly{{9,43},{55,43},{51,50},{44,57},{20,57},{14,50}}, W, 3)
D.ln(c,12,47,52,47,W[1]) D.ln(c,17,51,47,51,W[1])
D.lit(c:rect(9,41,55,43), W, 1)
c:px(31,10,D.CR)
for x = 3, 60 do
  local y0 = 54 + floor(1.5 * math.sin(x * 0.55) + .5)
  for y = y0, 59 do c:px(x, y, y == y0 and SE[6] or (y <= y0 + 1 and SE[4] or SE[3])) end
end
D.fin()
