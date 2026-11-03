local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-frog: green frog sitting, bulging eyes, wide mouth, pale belly.
-- quirk: it wears a tiny gold crown (a frog prince).
local c = D.new("ico-frog")
for _, fx in ipairs{ 14, 50 } do D.lit(c:ellipse(fx, 54, 8, 4), D.GREEN, 4) end
local body = c:ellipse(32, 40, 21, 16)
D.lit(body, D.GREEN, 14, { amb = 0.05 })
D.lit(D.isect(c:ellipse(32, 52, 13, 7), body), D.CREAM, 5)
for _, ex in ipairs{ 20, 44 } do
  D.lit(D.disc(ex, 25, 8), D.GREEN, 6, { amb = 0.05 })
  c:eyeLocked(ex - 2, 22)
end
D.poly(c, { {13,41},{20,46},{32,48},{44,46},{51,41} }, INK)
D.poly(c, { {13,40},{12,38} }, INK) D.poly(c, { {51,40},{52,38} }, INK)
c:px(29, 36, D.GREEN[2]) c:px(35, 36, D.GREEN[2])
D.fill(c:poly{ {27,18},{27,12},{30,15},{32,10},{34,15},{37,12},{37,18} }, "#f2bb2e")
D.fill(c:rect(27, 17, 37, 18), "#b0661c") c:px(32, 11, CR)
D.fin()
