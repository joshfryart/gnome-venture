-- Captain Pipi Shellback: green sea turtle skipper, cream cap + tapa band, navy jacket, shell behind shoulders, grey kitten in a flower lei
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-captain_pipi_shellback")
local R = M.R
local skin = R("#5cb84a", { hi = "#a0e070", shade = "#3a8a4a", deep = "#24584a" })
local belly = R("#e8e0a0", { hi = "#fff4c0", shade = "#b8aa70", deep = "#6a6a4a" })
local shell = R("#9a6a38", { hi = "#c89458", shade = "#6e4a30", deep = "#3e2a28" })
local navy = R("#2f4a9a", { hi = "#5a78c8", shade = "#22306e", deep = "#161e48" })
local cap = R("#f4e6c8", { hi = "#fff8e6", shade = "#cfae8a", deep = "#8a6a5a" })
local grey = R("#9a9aa8", { hi = "#c8c8d4", shade = "#6a6a84", deep = "#444663" })
local tapa = R("#8a5a34", { hi = "#c08a58", shade = "#5a3a2a", deep = "#34221f" })
-- shell behind
local sh = c:ellipse(39.5, 98, 39, 28):clip(c:rect(0, 66, 79, 99))
M.part(c, sh, shell, { band = 2, nopop = true })
for _, l in ipairs({ { { 6, 99 }, { 12, 84 }, { 22, 74 } }, { { 73, 99 }, { 67, 84 }, { 57, 74 } }, { { 3, 90 }, { 12, 84 } }, { { 76, 90 }, { 67, 84 } }, { { 22, 74 }, { 30, 68 } }, { { 57, 74 }, { 49, 68 } } }) do c:line(l, 1):clip(sh):each(function(x, y) M.keep(c, x, y, shell.deep) end) end
-- jacket
local jacket = c:ellipse(39.5, 106, 29, 28):clip(c:rect(0, 78, 79, 99))
M.part(c, jacket, navy, { band = 2, pop = { x = 24, y = 86 } })
local shirt = c:poly({ { 32, 78 }, { 47, 78 }, { 43, 99 }, { 36, 99 } })
M.part(c, shirt, cap, { band = 1, nopop = true })
c:line({ { 31, 78 }, { 37, 99 } }, 1):each(function(x, y) M.keep(c, x, y, navy.deep) end) c:line({ { 48, 78 }, { 42, 99 } }, 1):each(function(x, y) M.keep(c, x, y, navy.deep) end)
for i, p in ipairs({ { 36, 80 }, { 38, 83 }, { 41, 83 }, { 43, 80 }, { 40, 86 } }) do M.part(c, c:ellipse(p[1], p[2], 1.6, 1.6), { hi = "#fff4d6", base = "#f4c8c0", shade = "#c89498", deep = "#8a5a6a", mid = "#e0acac" }, { band = 1, nopop = true }) end
c:button(30, 92) c:button(50, 92)
-- neck + head
M.part(c, c:rect(31, 66, 48, 78), skin, { band = 2, nopop = true })
local head = c:ellipse(39.5, 54, 19.5, 16)
M.part(c, head, skin, { band = 3 })
-- pale muzzle
M.part(c, c:ellipse(39.5, 61, 11, 7), belly, { band = 2, nopop = true })
M.pts(c, { { 24, 58 }, { 25, 60 }, { 54, 58 }, { 53, 60 } }, skin.shade)
-- skipper cap: crown, tapa band, navy peak
local crown = c:ellipse(39.5, 30, 18, 8):clip(c:rect(0, 0, 79, 36)):add(c:rect(22, 30, 57, 37))
M.part(c, crown, cap, { band = 2, pop = { x = 28, y = 24 } })
local band = c:rect(22, 34, 57, 41)
M.part(c, band, tapa, { band = 1, nopop = true })
for x = 23, 56, 4 do M.pts(c, { { x, 36, "#f4e6c8" }, { x + 1, 37, "#f4e6c8" }, { x + 2, 38, "#f4e6c8" }, { x + 1, 39, "#f4e6c8" } }) end
local peak = c:ellipse(39.5, 42, 19, 3.4)
M.part(c, peak, navy, { band = 1, pop = { x = 28, y = 41 } })
c:fillMask(c:rect(37, 24, 42, 27), "#f5b82e")
-- frangipani at the side
for _, d in ipairs({ { 0, -3 }, { 3, -1 }, { 2, 3 }, { -2, 3 }, { -3, -1 } }) do M.part(c, c:ellipse(60 + d[1], 40 + d[2], 2.6, 2.6), { hi = "#fff4d6", base = "#fff0e0", shade = "#f0b8b0", deep = "#c88090", mid = "#f8d4c4" }, { band = 1, nopop = true }) end
c:fillMask(c:ellipse(60, 40, 1.6, 1.6), P.gold.base)
-- eyes + designed nose (two nostril dots on a pale muzzle) + grin
M.eyes(c, 30, 49, 44, 49)
M.pts(c, { { 29, 47 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 46, 46 }, { 47, 46 }, { 48, 46 }, { 49, 47 } }, skin.deep)
c:cheek(25, 57) c:cheek(53, 57)
c:paint({ "..hhhh..", ".bbbbbb.", "..nn.nn.." }, 35, 56, { h = belly.hi, b = belly.base, n = belly.deep })
M.pts(c, { { 33, 62 }, { 34, 63 }, { 35, 64 }, { 36, 64 }, { 37, 64 }, { 38, 64 }, { 39, 64 }, { 40, 64 }, { 41, 64 }, { 42, 64 }, { 43, 64 }, { 44, 63 }, { 45, 62 } }, skin.deep)
M.pts(c, { { 36, 63 }, { 43, 63 } }, "#fff4d6")
-- grey kitten with flower lei held in flippers, lower left
local kit = c:ellipse(18, 88, 8, 7.5)
M.part(c, c:poly({ { 11, 85 }, { 10, 78 }, { 16, 82 } }), grey, { band = 1, nopop = true }) M.part(c, c:poly({ { 25, 85 }, { 26, 78 }, { 20, 82 } }), grey, { band = 1, nopop = true })
M.part(c, kit, grey, { band = 2, pop = { x = 12, y = 85 } })
M.pts(c, { { 14, 87, "#2b1c26" }, { 21, 87, "#2b1c26" }, { 17, 90, "#e8909e" }, { 18, 90, "#e8909e" }, { 16, 83, grey.deep }, { 18, 83, grey.deep }, { 20, 83, grey.deep } })
for i, col in ipairs({ P.petal.base, P.gold.base, "#fff4d6", P.petal.base, P.gold.base, "#fff4d6" }) do
  local a = math.pi * (0.1 + 0.8 * (i - 1) / 5)
  local x, y = 18 + 8.5 * math.cos(a) * -1, 92 + 3 * math.sin(a)
  M.part(c, c:ellipse(x, y, 2.2, 2.2), { hi = "#fff4d6", base = col, shade = P.petal.shade, deep = P.petal.deep, mid = col }, { band = 1, nopop = true })
end
M.part(c, c:ellipse(30, 94, 4.6, 3.6), skin, { band = 1, nopop = true })
M.fin(c, "npc-captain_pipi_shellback", { base = "#7ad4d8", shade = "#52b4c0", deep = "#3a8ea8" })
