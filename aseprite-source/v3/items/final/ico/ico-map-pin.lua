local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-map-pin: red teardrop pin with cream hole above a dotted trail. quirk: the trail's last dot is a tiny x mark.
local c = D.new("ico-map-pin")
c:groundShadow(32, 56, 12, 3)
local pin = D.ell(32, 24, 15, 15):add(c:poly{{18,31},{46,31},{32,54}})
D.lit(pin, D.RED, 6)
D.fill(D.ell(32, 24, 6, 6), D.RED[1])
D.lit(D.ell(32, 24, 5, 5), D.CREAM, 3)
D.px(21, 15, D.RED[6]) D.px(22, 14, D.RED[6]) D.px(23, 13, D.RED[6])
for _, p in ipairs{{8,58},{14,60},{20,58}} do D.fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), D.GOLD[4]) end
D.ln(50, 55, 54, 59, D.RED[3]) D.ln(54, 55, 50, 59, D.RED[3])
D.fin()
