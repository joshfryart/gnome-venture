-- Didi Marigold: red panda auntie, marigold shawl over teal kurta, marigold by the ear, yarn ball with bell, striped tail
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-didi_marigold")
local R = M.R
local fur = R("#d8662c", { hi = "#f2904a", shade = "#a8442a", deep = "#6a2a2a" })
local white = R("#fff4e0", { hi = "#fffaf0", shade = "#e0c8b4", deep = "#a88a7a" })
local teal = R("#2a9a98", { hi = "#6ad8c8", shade = "#2a6e8a", deep = "#1f4a6e" })
local mari = R("#f5a22a", { hi = "#ffe07a", shade = "#d46a1f", deep = "#8a3a1f" })
local pink = R("#f5809f", { hi = "#ffc4d8", shade = "#c94f84", deep = "#7d2c5e" })
-- striped tail behind left shoulder
local tail = c:poly({ { 4, 100 }, { 6, 74 }, { 16, 62 }, { 26, 72 }, { 24, 100 } })
M.part(c, tail, fur, { band = 2, nopop = true })
for _, y in ipairs({ 70, 77, 84, 91 }) do tail:copy():clip(c:rect(0, y, 79, y + 2)):each(function(x, yy) M.keep(c, x, yy, white.base) end) end
-- kurta + marigold shawl
local kurta = c:ellipse(39.5, 104, 33, 28):clip(c:rect(0, 74, 79, 99))
M.part(c, kurta, teal, { band = 2, pop = { x = 24, y = 86 } })
local shawl = c:poly({ { 8, 100 }, { 12, 84 }, { 22, 74 }, { 39, 82 }, { 56, 74 }, { 68, 84 }, { 72, 100 } }):clip(c:rect(0, 0, 79, 99))
shawl:cut(c:poly({ { 28, 78 }, { 39, 100 }, { 51, 78 }, { 60, 100 }, { 20, 100 } }))
M.part(c, shawl, mari, { band = 2, pop = { x = 14, y = 86 } })
for y = 88, 98, 5 do shawl:copy():clip(c:rect(0, y, 79, y)):each(function(x, yy) if x % 4 < 2 then M.keep(c, x, yy, mari.shade) end end) end
c:stitch({ { 29, 80 }, { 39, 99 } }) c:stitch({ { 50, 80 }, { 41, 99 } })
-- ruff of white fur around neck
local ruff = c:ellipse(39.5, 72, 22, 6)
M.part(c, ruff, white, { band = 1, nopop = true })
for x = 20, 60, 5 do M.pts(c, { { x, 77, white.shade }, { x + 1, 76, white.hi } }) end
-- ears: pointed, white-edged
for _, e in ipairs({ { { 24, 42 }, { 20, 18 }, { 38, 36 } }, { { 55, 42 }, { 59, 18 }, { 41, 36 } } }) do
  M.part(c, c:poly({ e[1], e[2], e[3] }), fur, { band = 1, nopop = true })
  c:fillMask(c:poly({ { e[1][1] + (e[2][1] > 39 and -1 or 2), e[1][2] }, { e[2][1] + (e[2][1] > 39 and -1 or 1), e[2][2] + 5 }, { e[3][1] + (e[2][1] > 39 and 1 or -2), e[3][2] + 1 } }), white.base)
end
-- head
local head = c:ellipse(39.5, 54, 20, 17)
M.part(c, head, fur, { band = 3 })
-- white face mask: cheeks + muzzle + brow dots
local mask = c:ellipse(39.5, 61, 17, 10):add(c:ellipse(39.5, 54, 8, 6))
mask:clip(head)
M.part(c, mask, white, { band = 2, nopop = true })
M.pts(c, { { 31, 44 }, { 32, 44 }, { 47, 44 }, { 48, 44 } }, white.base)
-- tear-line markings under eyes
M.pts(c, { { 29, 54 }, { 28, 56 }, { 27, 58 }, { 50, 54 }, { 51, 56 }, { 52, 58 } }, fur.base)
M.eyes(c, 30, 47, 44, 47)
M.pts(c, { { 29, 45 }, { 30, 44 }, { 31, 44 }, { 32, 44 }, { 47, 44 }, { 48, 44 }, { 49, 44 }, { 50, 45 } }, fur.deep)
c:cheek(25, 56) c:cheek(53, 56)
-- designed nose: dark rounded triangle + lit tip + philtrum
c:paint({ ".hhhh.", "nnnnnn", ".nnnn.", "..ss.." }, 37, 54, { h = "#8a6a70", n = "#3a2430", s = "#3a2430" })
M.pts(c, { { 39, 58 }, { 40, 58 }, { 39, 59 }, { 40, 59 }, { 37, 60 }, { 38, 60 }, { 41, 60 }, { 42, 60 }, { 39, 61 }, { 40, 61 } }, white.deep)
-- marigold flower tucked by the right ear
for _, p in ipairs({ { 54, 36 }, { 58, 38 }, { 60, 34 }, { 56, 32 }, { 52, 33 } }) do M.part(c, c:ellipse(p[1], p[2], 3, 3), mari, { band = 1, nopop = true }) end
c:fillMask(c:ellipse(56, 35, 2, 2), mari.deep) M.pts(c, { { 55, 34 } }, mari.hi)
-- yarn ball (felt) with a bell, held lower right
local yarn = c:ellipse(61, 90, 8, 8):clip(c:rect(0, 0, 79, 99))
M.part(c, yarn, pink, { band = 2, pop = { x = 56, y = 85 } })
for _, l in ipairs({ { { 55, 88 }, { 60, 84 }, { 66, 85 } }, { { 54, 92 }, { 62, 87 }, { 68, 90 } }, { { 56, 96 }, { 64, 92 }, { 68, 95 } } }) do c:line(l, 1):clip(yarn):each(function(x, y) M.keep(c, x, y, pink.shade) end) end
c:fillMask(c:rect(59, 77, 63, 80), P.gold.base) M.pts(c, { { 59, 77 }, { 60, 77 } }, P.gold.hi) M.pts(c, { { 61, 80 } }, P.gold.deep)
M.part(c, c:ellipse(52, 94, 4, 3.4), fur, { band = 1, nopop = true })
M.fin(c, "npc-didi_marigold", { base = "#8a6fd0", shade = "#6a52b0", deep = "#4a3a88" })
