local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-test-tube: glass test tube tilted on the diagonal, green liquid inside, cork stopper, glassy rim.
-- quirk: bubbles rise from the potion and one has escaped over the cork.
local c = D.new("ico-test-tube")
local tube, T = D.sweep({ {44,14},{40,26},{26,40},{16,52} }, function() return 6 end, 50)
local tm = tube:copy():add(D.ell(16, 52, 6.5, 6.5))
D.lit(c, tm, D.GRY, 6, { amb = 0.3 })
tm:each(function(x, y) c:px(x, y, (x + y) % 2 == 0 and D.GRY[5] or D.GRY[6]) end)
local lq = tm:copy():shrink(1):clip(c:poly{ {0,63},{63,63},{63,0},{51,0},{29,37},{0,37} })
lq:clip(c:poly{ {0,63},{0,36},{40,26},{63,50},{63,63} })
D.lit(c, lq, D.GRN, 6, { amb = 0.08 })
D.rect(c, 11, 49, 14, 50, D.GRN[6])
tm:each(function(x, y) if not tm:has(x + 1, y + 1) and not lq:has(x, y) then c:px(x, y, D.GRY[3]) end end)
lq:each(function(x, y) if not lq:has(x, y - 1) then c:px(x, y, D.GRN[6]) end end)
local cork = c:poly{ {40,9},{51,9},{49,17},{42,17} } D.lit(c, c:poly{ {37,10},{48,7},{52,12},{41,15} }, D.BRN, 4, { amb = 0.15 })
D.rect(c, 43, 10, 44, 10, D.BRN[6]) c:px(47, 11, D.BRN[2])
D.bubble(c, 22, 44, 2) D.bubble(c, 29, 33, 2) D.bubble(c, 55, 8, 3) D.rect(c, 56, 2, 57, 3, D.BLU[5])
D.fin()
