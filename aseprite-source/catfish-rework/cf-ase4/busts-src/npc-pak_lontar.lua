-- Pak Lontar: water buffalo shopkeeper, black peci cap, big curved horns, indigo batik shirt, kitten in a paddy-hat bed
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-pak_lontar")
local R = M.R
local fur = R("#6a5560", { hi = "#9a8088", shade = "#4a3a4e", deep = "#2e2436" })
local muz = R("#c8a0a0", { hi = "#ecc8bc", shade = "#9a6a78", deep = "#5a3a4a" })
local horn = R("#e8dcc0", { hi = "#fff0d8", shade = "#b8a088", deep = "#7a6450" })
local peci = R("#3a3448", { hi = "#6a5e80", shade = "#241e34", deep = "#14101e" })
local indigo = R("#3a4a9a", { hi = "#6a80d0", shade = "#2a3070", deep = "#1a1a48" })
local straw = R("#e0b860", { hi = "#fff0a0", shade = "#b8843a", deep = "#7a4a22" })
local ginger = R("#ee9040", { hi = "#ffd08a", shade = "#c4602a", deep = "#7a3a1c" })
-- batik shirt
local shirt = c:ellipse(39.5, 104, 35, 28):clip(c:rect(0, 74, 79, 99))
M.part(c, shirt, indigo, { band = 2, pop = { x = 14, y = 84 } })
for y = 80, 98, 6 do for x = (y % 12 == 2 and 6 or 3), 79, 8 do
  for _, d in ipairs({ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } }) do if shirt:has(x + d[1], y + d[2]) then M.keep(c, x + d[1], y + d[2], "#f5b82e") end end
  if shirt:has(x, y) then M.keep(c, x, y, "#ffe38a") end
end end
-- neck
local neck = c:rect(30, 66, 49, 78)
M.part(c, neck, fur, { band = 2, nopop = true })
c:fillMask(c:rect(31, 76, 48, 78), indigo.shade)
M.part(c, c:ellipse(39.5, 77, 11, 2.6), { hi = indigo.hi, base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f", mid = "#e89d28" }, { band = 1, nopop = true })
-- horns: sweeping crescents out and up
for _, s in ipairs({ -1, 1 }) do
  local cx = 39.5
  local hm = c:poly({ { cx + s * 18, 48 }, { cx + s * 28, 44 }, { cx + s * 33, 34 }, { cx + s * 32, 22 }, { cx + s * 29, 17 }, { cx + s * 29, 30 }, { cx + s * 25, 38 }, { cx + s * 18, 40 } })
  M.part(c, hm, horn, { band = 2, nopop = true })
  c:poly({ { cx + s * 32, 22 }, { cx + s * 29, 17 }, { cx + s * 29, 26 }, { cx + s * 31, 26 } }):each(function(x, y) M.keep(c, x, y, horn.deep) end)
end
-- ears below horns
for _, e in ipairs({ { 17, 52 }, { 62, 52 } }) do M.part(c, c:ellipse(e[1], e[2], 5, 3.6), fur, { band = 1, nopop = true }) c:fillMask(c:ellipse(e[1], e[2] + 1, 3, 1.6), muz.base) end
-- head
local head = c:ellipse(39.5, 52, 19.5, 17)
M.part(c, head, fur, { band = 3 })
M.ticks(c, head:copy():clip(c:rect(0, 0, 79, 45)), fur.hi, 7, 3)
-- peci cap: tall velvet box with gold band
local cap = c:rrect(28, 26, 51, 38, 3)
M.part(c, cap, peci, { band = 2, pop = { x = 32, y = 28 } })
c:fillMask(c:rect(28, 34, 51, 37), "#f5b82e") c:fillMask(c:rect(28, 37, 51, 37), "#d98322") c:stitch({ { 29, 35 }, { 50, 35 } })
M.pts(c, { { 33, 31, peci.hi }, { 34, 31, peci.hi } })
-- muzzle: wide, pink-grey with big nostrils (designed nose)
local snout = c:ellipse(39.5, 62, 13.5, 8.5)
M.part(c, snout, muz, { band = 2, nopop = true })
c:paint({ "..hhhhhh..", ".nnnnnnnn.", ".nnn..nnn.", "..........", "...ssss..." }, 34, 57, { h = muz.hi, n = muz.shade, s = muz.deep })
M.pts(c, { { 36, 59 }, { 37, 59 }, { 42, 59 }, { 43, 59 } }, "#2e2436") M.pts(c, { { 36, 58 }, { 43, 58 } }, "#2e2436")
M.pts(c, { { 34, 66 }, { 35, 67 }, { 36, 67 }, { 37, 67 }, { 38, 66 }, { 41, 66 }, { 42, 67 }, { 43, 67 }, { 44, 67 }, { 45, 66 } }, muz.deep)
-- brows + locked eyes
M.eyes(c, 28, 46, 46, 46)
M.pts(c, { { 27, 44 }, { 28, 43 }, { 29, 43 }, { 30, 43 }, { 31, 44 }, { 47, 44 }, { 48, 43 }, { 49, 43 }, { 50, 43 }, { 51, 44 } }, fur.deep)
M.pts(c, { { 24, 50 }, { 25, 52 }, { 54, 52 }, { 55, 50 } }, fur.shade)
c:cheek(24, 56) c:cheek(54, 56)
-- paddy-hat bed with ginger kitten
local kit = c:ellipse(39.5, 86, 8, 6.5)
M.part(c, c:poly({ { 33, 82 }, { 32, 76 }, { 38, 80 } }), ginger, { band = 1, nopop = true }) M.part(c, c:poly({ { 46, 82 }, { 47, 76 }, { 41, 80 } }), ginger, { band = 1, nopop = true })
M.part(c, kit, ginger, { band = 2, pop = { x = 34, y = 82 } })
M.pts(c, { { 36, 85, "#2b1c26" }, { 43, 85, "#2b1c26" }, { 39, 88, "#e8909e" }, { 40, 88, "#e8909e" }, { 38, 83, ginger.shade }, { 39, 82, ginger.shade }, { 41, 83, ginger.shade } })
local bed = c:ellipse(39.5, 96, 21, 8):clip(c:rect(0, 90, 79, 99))
M.part(c, bed, straw, { band = 2, pop = { x = 24, y = 93 } })
for x = 20, 60, 4 do M.pts(c, { { x, 93, straw.shade }, { x + 2, 95, straw.shade }, { x, 97, straw.shade } }) end
bed:copy():clip(c:rect(0, 90, 79, 91)):each(function(x, y) M.keep(c, x, y, straw.hi) end)
M.part(c, c:ellipse(21, 92, 4.6, 3.6), fur, { band = 1, nopop = true }) M.part(c, c:ellipse(58, 92, 4.6, 3.6), fur, { band = 1, nopop = true })
M.fin(c, "npc-pak_lontar", { base = "#9adccc", shade = "#72bcb0", deep = "#4a9a98" })
