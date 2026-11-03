local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-pointing: a cartoon hand with a long index finger pointing right, curled fingers and a blue cuff.
-- quirk: a chunky gold ring sits on the pointing finger.
local c = D.new("ico-pointing")
local cuff = c:rrect(5, 20, 15, 46, 2)
D.lit(c, cuff, D.BLU, 4)
D.rect(c, 6, 28, 14, 28, D.BLU[5]) 
local palm = c:rrect(14, 22, 37, 46, 5)
D.lit(c, palm, D.SKIN, 8, { amb = 0.1 })
for i, y in ipairs{ 38, 42 } do
  D.lit(c, c:ellipse(30, y, 9, 3), D.SKIN, 2)
  D.rect(c, 22, y + 3, 38, y + 3, D.SKIN[1])
end
local idx = c:rrect(26, 24, 59, 34, 5)
D.lit(c, idx, D.SKIN, 5, { amb = 0.1 })
D.lit(c, c:ellipse(25, 20, 6, 4), D.SKIN, 3)
D.rect(c, 22, 24, 30, 24, D.SKIN[2])
D.rect(c, 49, 24, 51, 34, D.YEL[3]) D.rect(c, 49, 24, 49, 34, D.YEL[5]) D.rect(c, 51, 24, 51, 34, D.YEL[1])
D.pts(c, { {55, 26}, {56, 26}, {57, 28} }, D.SKIN[6])
D.fin()
