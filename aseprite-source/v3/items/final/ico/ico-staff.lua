local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-staff: slim diagonal wizard staff, gnarled wood shaft topped by a blue orb in gold claws.
-- quirk: a little green leaf has sprouted out of the shaft.
local c = D.new("ico-staff")
D.cyl(c, 10, 57, 42, 24, function(t) return 2.4 + (1 - t) * 0.6 end, D.BRN, { amb = 0.08 })
D.ln(c, 12, 53, 38, 26, D.BRN[5])
D.leaf(c, 28, 38, 24, 28, 4, D.GRN, {})
D.leaf(c, 28, 38, 36, 40, 1, D.GRN)
D.lit(c, D.ell(44, 21, 3, 8, -0.78):add(D.ell(41, 24, 7, 3, -0.78)), D.ORG, 3)
D.disc(c, 47, 17, 8, D.BLU)
D.rect(c, 43, 12, 44, 13, D.BLU[6]) c:px(45, 11, D.BLU[6]) c:px(44, 14, D.CRM[6])
c:sparkle(55, 8)
for _, q in ipairs{ {38,23,40,15},{42,26,52,22},{39,25,40,27} } do D.ln(c, q[1], q[2], q[3], q[4], D.YEL[3]) end
D.fin()
