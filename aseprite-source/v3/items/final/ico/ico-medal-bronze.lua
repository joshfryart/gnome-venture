local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-medal-bronze: hexagon-edged bronze disc with a bold 3, green ribbon. quirk: a tiny chip has been bitten from the rim.
local c = D.new("ico-medal-bronze")
D.lit(c:poly{{20,4},{32,4},{32,28},{26,34},{20,28}}, D.GREEN, 1.5)
D.lit(c:poly{{32,4},{44,4},{44,28},{38,34},{32,28}}, "moss", 1.5)
local hex = c:poly{{32,26},{46,32},{46,48},{32,58},{18,48},{18,32}}
hex:cut(D.ell(46, 47, 3, 2))
D.lit(hex, D.BRZ, 6)
D.fill(D.sub(D.disc(32, 42, 11), D.disc(32, 42, 9)), D.BRZ[2])
D.fill(c:rect(27, 36, 37, 38), D.BRZ[6]) D.fill(c:rect(35, 36, 37, 48), D.BRZ[6]) D.fill(c:rect(27, 41, 37, 43), D.BRZ[6]) D.fill(c:rect(27, 46, 37, 48), D.BRZ[6])
D.fill(c:rect(27, 48, 37, 48), D.BRZ[1])
D.px(23, 34, D.BRZ[6]) D.px(24, 33, D.BRZ[6])
D.fin()
