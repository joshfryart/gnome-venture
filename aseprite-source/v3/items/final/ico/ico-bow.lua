-- ico-bow first draft (Sonnet). quirk: a ribbon wrapped round the grip
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bow"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local arc = D.B.H.sweep({{22,6},{0,24},{0,40},{22,58}}, function(t) return 1.6 + 1.2 * math.sin(math.pi * t) end)
D.lit(arc, W, 1.5)
D.fill(c:rect(22,7,23,57), D.CREAM[3])
D.lit(c:rect(4,26,10,38), D.RED, 1.5)
D.fill(c:rect(14,31,52,33), W[3]) D.lit(c:rect(14,31,52,33), W, 1)
D.lit(c:poly{{50,28},{58,32},{50,36}}, ST, 1)
D.lit(c:poly{{24,28},{34,28},{36,32},{34,36},{24,36},{26,32}}, D.RED, 1)
D.fin()
