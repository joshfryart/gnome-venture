local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-corn: gold ear of corn with kernel rows, two green husk leaves and a silk tuft.
-- quirk: one lone purple kernel among the gold.
local c = D.new("ico-corn")
D.leaf = D.H.leaf
D.H.leaf(c, 32, 56, 12, 22, 7, "moss", { 6, 12 })
D.H.leaf(c, 32, 56, 52, 26, 7, "moss", { 6, 12 })
local cob = D.ell(32, 28, 9, 21, 0)
D.lit(cob, D.GOLD, 8)
-- kernels: grid of dark seams
cob:each(function(x, y)
  if (x - 23) % 4 == 0 and y > 14 then D.px(x, y, D.GOLD[2]) end
  if ((y - 8) % 4 == 0) and ((x % 4) ~= 1) then D.px(x, y, D.GOLD[2]) end
end)
for _, p in ipairs{ { 27, 18 }, { 28, 18 }, { 28, 26 }, { 36, 34 } } do D.px(p[1], p[2], D.GOLD[6]) end
D.fill(c:rect(33, 33, 35, 35), D.PURP[4]) D.px(33, 33, D.PURP[6])
-- front husk overlapping cob base
D.H.leaf(c, 32, 58, 26, 34, 5, "moss", { 5 })
D.H.leaf(c, 32, 58, 39, 36, 5, "moss", { 5 })
-- silk
D.fill(c:line({ { 32, 8 }, { 30, 4 }, { 26, 3 } }, 2), "#f3c46c")
D.fill(c:line({ { 33, 8 }, { 36, 4 }, { 40, 4 } }, 2), "#dc9550")
D.fin()
