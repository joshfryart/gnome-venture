local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-spider: round orange-bellied spider, eight bent purple legs, two eyes and a clear fanged mouth.
-- quirk: it dangles on a silk thread and wears a tiny red bow tie.
local c = D.new("ico-spider")
local L = { {{26,34},{14,26},{6,34},{8,46}}, {{26,38},{12,38},{7,46},{9,56}}, {{26,30},{14,18},{8,22},{6,14}}, {{27,42},{16,48},{14,58}} }
for _, p in ipairs(L) do
  for s = -1, 1, 2 do
    local q = {} for i, v in ipairs(p) do q[i] = { s == 1 and v[1] or 63 - v[1], v[2] } end
    for i = 1, #q - 1 do D.ln(c, q[i][1], q[i][2], q[i+1][1], q[i+1][2], D.PURP[3]) D.ln(c, q[i][1], q[i][2] + 1, q[i+1][1], q[i+1][2] + 1, D.PURP[2]) end
  end
end
D.ln(c, 32, 0, 32, 15, D.CRM[3])
D.disc(c, 32, 42, 11, D.ORG) D.rect(c, 28, 44, 36, 46, D.ORG[2]) c:px(27, 38, D.ORG[6]) c:px(28, 37, D.ORG[6])
D.disc(c, 32, 26, 8, D.PURP)
c:eyeSmall(27, 21) c:eyeSmall(34, 21)
c:fillMask(c:rect(31, 26, 32, 27), D.INK) D.rect(c, 29, 30, 30, 31, D.CRM[6]) D.rect(c, 34, 30, 35, 31, D.CRM[6])
-- bow tie
c:fillMask(c:poly{ {26,32},{31,34},{26,37} }, D.RED[4]) c:fillMask(c:poly{ {38,32},{33,34},{38,37} }, D.RED[4])
D.rect(c, 31, 33, 33, 35, D.RED[2])
D.fin()
