-- Coral Pennyfeather: flamingo shopkeeper, madras head tie, feather-wand prop (quirk)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-coral_pennyfeather")
local R = M.R
local pink = R("#f6a08c", { hi = "#ffc9aa", shade = "#e27c7a", deep = "#b95a6c" })
local turq = R("#3fb5ad", { hi = "#8ae8d0", shade = "#2a8a98", deep = "#1f5a6e" })
local mad = R("#d8453f", { hi = "#ff8a6a", shade = "#a82a38", deep = "#6a1a2e" })
local cream = R("#fff4d6", { hi = "#fffaf0", shade = "#e8c9a4", deep = "#b8906e" })
local beak = R("#fff0dc", { hi = "#fff0d8", shade = "#f0b8a8", deep = "#6e3040" })
local wood = P.wood
-- blouse + apron
local blouse = c:ellipse(39.5, 103, 33, 27):clip(c:rect(0, 72, 79, 99))
M.part(c, blouse, turq, { band = 2 })
local apron = c:poly({ { 28, 80 }, { 51, 80 }, { 56, 100 }, { 23, 100 } })
M.part(c, apron, cream, { band = 2, nopop = true })
c:line({ { 30, 90 }, { 49, 90 } }, 1):each(function(x, y) M.keep(c, x, y, cream.shade) end)
-- conch pendant on a string
M.pts(c, { { 36, 76 }, { 37, 78 }, { 38, 80 }, { 43, 76 }, { 42, 78 }, { 41, 80 } }, P.stone.shade)
c:paint({ ".ww.", "wcww", "wwcw", ".ww." }, 38, 80, { w = "#fff0d8", c = "#e8a89a" })
-- neck + head
local neck = c:rect(33, 66, 46, 76)
M.part(c, neck, pink, { band = 2, nopop = true })
local head = c:ellipse(39.5, 52, 19.5, 17)
M.part(c, head, pink, { band = 3 })
-- feather tufts on cheeks
M.pts(c, { { 22, 56 }, { 23, 58 }, { 57, 56 }, { 56, 58 } }, pink.shade)
-- head tie
local wrap = c:ellipse(39.5, 43, 21, 14):clip(c:rect(0, 0, 79, 48))
wrap:add(c:rrect(18, 42, 61, 47, 2))
local knot = c:ellipse(58, 33, 6, 5):add(c:ellipse(64, 38, 4.5, 4)):add(c:poly({ { 58, 36 }, { 64, 44 }, { 60, 46 }, { 54, 38 } }))
M.part(c, knot, mad, { band = 1, nopop = true })
M.part(c, wrap, mad, { band = 2, pop = { x = 30, y = 33 } })
local inner = wrap:copy():add(knot):cut(wrap:copy():shift(0, 0):clip(c:rect(0, 0, 0, 0)))
for x = 20, 66, 5 do inner:copy():clip(c:rect(x, 0, x, 99)):each(function(xx, yy) if c:get(xx, yy) == mad.base or c:get(xx, yy) == mad.hi then M.keep(c, xx, yy, "#f5cf6a") end end) end
for _, y in ipairs({ 34, 40 }) do inner:copy():clip(c:rect(0, y, 79, y)):each(function(xx, yy) if c:get(xx, yy) ~= mad.shade and c:get(xx, yy) ~= mad.deep then M.keep(c, xx, yy, "#4f9a45") end end) end
c:stitch({ { 19, 47 }, { 60, 47 } })
-- eyes, cheeks
M.eyes(c, 30, 49, 44, 49)
M.pts(c, { { 29, 47 }, { 30, 46 }, { 31, 46 }, { 32, 46 } }, pink.shade) M.pts(c, { { 45, 46 }, { 46, 46 }, { 47, 46 }, { 48, 47 } }, pink.shade)
c:cheek(25, 56) c:cheek(53, 56)
-- designed beak: wide pale bill, bent down, black tip
local bill = c:poly({ { 33, 52 }, { 45, 52 }, { 49, 57 }, { 50, 63 }, { 47, 68 }, { 43, 63 }, { 39, 60 }, { 33, 58 } })
M.part(c, bill, beak, { band = 2, nopop = true })
bill:copy():cut(bill:copy():shrink(1)):each(function(x, y) M.keep(c, x, y, "#d98a86") end)
local tip = bill:copy():clip(c:poly({ { 43, 59 }, { 52, 57 }, { 52, 70 }, { 43, 70 } }))
tip:each(function(x, y) M.keep(c, x, y, (c:get(x, y) == beak.shade) and "#3a1f2e" or "#6e3040") end)
M.pts(c, { { 37, 54 }, { 38, 54 }, { 39, 54 } }, beak.hi)
M.pts(c, { { 37, 55 }, { 41, 55 } }, beak.deep)  -- nostrils
M.pts(c, { { 36, 60 }, { 37, 60 }, { 38, 61 } }, "#d98a86")
-- wing hand + wand
local stick = c:line({ { 62, 90 }, { 65, 66 }, { 69, 44 } }, 2)
M.part(c, stick, wood, { flat = true, nopop = true, band = 1 })
local wing = c:ellipse(61, 90, 6, 5.5)
M.part(c, wing, pink, { band = 2 })
-- feathers + bell
for _, f in ipairs({ { { 69, 44 }, { 66, 28 }, "ember" }, { { 69, 44 }, { 72, 26 }, "gold" }, { { 69, 44 }, { 76, 31 }, turq } }) do
  local fe = c:poly({ { f[1][1] - 1, f[1][2] }, { f[2][1] - 2, f[2][2] + 3 }, { f[2][1], f[2][2] }, { f[2][1] + 2, f[2][2] + 3 }, { f[1][1] + 1, f[1][2] } })
  M.part(c, fe, f[3] == "ember" and P.ember or (f[3] == "gold" and P.gold or turq), { band = 1, nopop = true })
end
M.pts(c, { { 70, 48 }, { 70, 50 } }, "#d98322")
c:fillMask(c:rect(69, 51, 71, 53), P.gold.base) M.pts(c, { { 69, 51 } }, P.gold.hi)
M.fin(c, "npc-coral_pennyfeather", { base = "#a9d6ea", shade = "#7fb4d8", deep = "#5f94c0" })
