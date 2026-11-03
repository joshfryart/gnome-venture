local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-circus-tent")
local CR, INK = D.CR, D.INK
-- ico-circus-tent: striped big-top, red and cream wedges, scalloped roof hem, dark door flap, gold flag on a pole.
-- quirk: a pair of oversized clown shoes pokes out under the door flap.
c:groundShadow(32, 58, 24, 2)
local body = c:rect(11, 33, 52, 55)
local roof = c:poly{ {32, 8}, {58, 33}, {6, 33} }
D.lit(body, D.CREAM, 4, { amb = 0.15 })
for x = 11, 52, 10 do D.lit(c:rect(x, 33, x + 4, 55):clip(body), D.RED, 3) end
D.lit(roof, D.CREAM, 6, { amb = 0.15 })
for i, a in ipairs{ 9, 18, 27, 36, 45 } do
  D.lit(c:poly{ {32, 8}, {a + 3, 33}, {a + 10, 33} }:clip(roof), D.RED, 3)
end
for x = 6, 52, 8 do D.lit(c:ellipse(x + 4, 33, 4, 3):clip(c:rect(0, 33, 63, 36)), (x // 8) % 2 == 0 and D.CREAM or D.RED, 2) end
D.lit(c:poly{ {32, 38}, {40, 55}, {24, 55} }, D.DKP, 3)
D.poly(c, { {32, 40}, {32, 54} }, D.DKP[1])
D.rect(32, 1, 32, 10, D.WOODR[3]); D.fill(c:poly{ {33, 1}, {41, 3}, {33, 6} }, "#f8cc3e")
D.lit(c:ellipse(27, 56, 3, 2), D.YEL, 2) D.lit(c:ellipse(37, 56, 3, 2), D.YEL, 2)
D.fin()
