local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-compost: dark heap of compost with an apple core, an eggshell half and a green leaf scrap, steaming.
-- quirk: a pink worm pokes out of the side of the heap.
local c = D.new("ico-compost")
c:groundShadow(32, 54, 24, 3)
local heap = D.isect(D.ell(32, 46, 24, 17), c:rect(0, 0, 63, 53))
D.lit(heap, D.BRN, 9, { amb = 0.05 })
-- speckle crumbs
local rnd = 7
heap:each(function(x, y) rnd = (rnd * 73 + x * 31 + y * 17) % 97
  if rnd < 7 then D.px(x, y, D.BRN[2]) elseif rnd > 91 then D.px(x, y, D.BRN[5]) end end)
-- apple core
D.lit(D.ell(24, 32, 5, 6.5, 0.2), D.RED, 3)
D.fill(c:rect(22, 31, 26, 34), D.CREAM[5]) D.fill(c:rect(23, 32, 25, 33), D.CREAM[3])
D.px(24, 27, D.BRN[3]) D.px(24, 26, D.BRN[2])
-- eggshell half
local egg = D.isect(D.ell(40, 33, 6, 6), c:rect(30, 33, 50, 40))
D.lit(egg, D.CREAM, 3)
D.fill(c:rect(35, 32, 36, 33), D.CREAM[5]) D.fill(c:rect(43, 32, 45, 33), D.CREAM[3])
-- leaf scrap
D.lit(D.ell(31, 40, 5, 2.2, -0.4), "moss", 1.6)
-- worm
D.fill(c:line({ { 54, 50 }, { 58, 47 }, { 57, 43 } }, 3), "#e8789a")
D.px(57, 42, D.INK) D.px(56, 44, "#ffb8cc")
-- steam
for _, s in ipairs{ { 27, 22 }, { 36, 20 } } do
  D.fill(c:line({ { s[1], s[2] }, { s[1] + 3, s[2] - 4 }, { s[1], s[2] - 8 }, { s[1] + 3, s[2] - 12 } }, 2), D.CREAM[5])
end
D.fin()
