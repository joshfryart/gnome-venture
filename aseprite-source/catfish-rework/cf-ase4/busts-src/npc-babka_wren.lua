-- Babka Wren: little brown wren grandma, red polka scarf, round gold spectacles, blue felt fish toy
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-babka_wren")
local R = M.R
local brown = R("#b08050", { hi = "#d8aa72", shade = "#7e5238", deep = "#4a2e2c" })
local barred = R("#8a5a38", { hi = "#b8864e", shade = "#5a3a2e", deep = "#34221f" })
local cream = R("#f4e6c8", { hi = "#fff8e6", shade = "#cfae8a", deep = "#8a6a5a" })
local red = R("#d8453f", { hi = "#ff8a6a", shade = "#a82a38", deep = "#6a1a2e" })
local beak = R("#f0a83a", { hi = "#ffe08a", shade = "#c47a22", deep = "#7a3e18" })
local blue = R("#4f8fd8", { hi = "#a8d4ff", shade = "#3a5ab0", deep = "#2a3a7a" })
-- cocked tail behind right shoulder
local tail = c:poly({ { 56, 90 }, { 64, 58 }, { 74, 52 }, { 76, 60 }, { 70, 90 } })
M.part(c, tail, barred, { band = 2, nopop = true })
for _, y in ipairs({ 62, 68, 74, 80, 86 }) do tail:copy():clip(c:rect(0, y, 79, y + 1)):each(function(x, yy) M.keep(c, x, yy, barred.deep) end) end
-- cream shawl with red diamond border
local shawl = c:ellipse(39.5, 104, 36, 30):clip(c:rect(0, 72, 79, 99))
M.part(c, shawl, cream, { band = 2, pop = { x = 16, y = 82 } })
for x = 4, 79, 8 do
  for _, d in ipairs({ { 0, -2 }, { -1, -1 }, { 1, -1 }, { -2, 0 }, { 2, 0 }, { -1, 1 }, { 1, 1 }, { 0, 2 } }) do if shawl:has(x + d[1], 92 + d[2]) then M.keep(c, x + d[1], 92 + d[2], red.base) end end
  if shawl:has(x, 92) then M.keep(c, x, 92, "#f5cf6a") end
end
shawl:copy():clip(c:rect(0, 97, 79, 97)):each(function(x, y) M.keep(c, x, y, red.shade) end)
M.part(c, c:ellipse(39.5, 74, 11, 3), cream, { band = 1, nopop = true })
-- head
local head = c:ellipse(39.5, 52, 19.5, 17)
M.part(c, head, brown, { band = 3 })
-- scarf (red, cream dots), tied under chin
local face = c:ellipse(39.5, 57, 15, 13)
local scarf = c:ellipse(39.5, 49, 23, 21):cut(face):clip(c:rect(0, 0, 79, 71))
M.part(c, scarf, red, { band = 2, pop = { x = 28, y = 34 } })
for _, p in ipairs({ { 30, 33 }, { 38, 31 }, { 46, 33 }, { 24, 38 }, { 34, 37 }, { 43, 37 }, { 55, 39 }, { 20, 46 }, { 58, 47 }, { 19, 54 }, { 61, 55 }, { 20, 62 }, { 60, 63 } }) do
  if scarf:has(p[1], p[2]) then M.keep(c, p[1], p[2], "#fff4d6") M.keep(c, p[1] + 1, p[2], "#fff4d6") end
end
c:stitch({ { 21, 60 }, { 22, 53 }, { 26, 46 }, { 33, 42 } }) c:stitch({ { 58, 60 }, { 57, 53 }, { 53, 46 }, { 46, 42 } })
c:fillMask(c:poly({ { 33, 71 }, { 28, 79 }, { 34, 80 }, { 37, 74 } }), red.base) c:fillMask(c:poly({ { 46, 71 }, { 51, 79 }, { 45, 80 }, { 42, 74 } }), red.base)
M.part(c, c:ellipse(39.5, 71, 6, 2.6), red, { band = 1, nopop = true })
-- barred cheeks
M.pts(c, { { 23, 56 }, { 24, 58 }, { 25, 60 }, { 56, 56 }, { 55, 58 }, { 54, 60 } }, brown.shade)
-- eyes + round gold spectacles
M.eyes(c, 30, 47, 44, 47)
for _, ex in ipairs({ 32, 46 }) do
  local ring = c:ellipse(ex, 49, 6, 5.5)
  ring:copy():cut(c:ellipse(ex, 49, 4, 3.6)):each(function(x, y) M.keep(c, x, y, "#f5b82e") end)
  M.pts(c, { { ex - 4, 46, "#ffe38a" }, { ex - 3, 45, "#ffe38a" }, { ex + 3, 53, "#d98322" } })
end
c:fillMask(c:rect(37, 48, 41, 48), "#f5b82e")
-- designed beak: short pointed, lit ridge, nostril
c:paint({ "..wwwwww..", ".whhhhwmm.", ".wwwwwmmm.", "..wwwmmm..", "...wmmm...", "....mm...." }, 34, 52, { w = beak.base, h = beak.hi, m = beak.shade })
M.pts(c, { { 37, 53 }, { 40, 53 } }, beak.deep)
M.pts(c, { { 36, 59 }, { 37, 60 }, { 38, 60 }, { 39, 60 }, { 40, 60 }, { 41, 60 }, { 42, 60 }, { 43, 59 } }, beak.deep)
-- blue felt fish in her wing, lower right
local wing = c:ellipse(60, 91, 6, 4.6)
local fish = c:ellipse(60, 84, 8, 3.8):add(c:poly({ { 67, 84 }, { 73, 79 }, { 73, 89 } }))
M.part(c, fish, blue, { band = 1, pop = { x = 55, y = 82 } })
M.pts(c, { { 55, 83, "#2b1c26" }, { 59, 84, blue.shade }, { 62, 84, blue.shade }, { 65, 84, blue.shade } })
M.part(c, wing, brown, { band = 2, nopop = true })
M.fin(c, "npc-babka_wren", { base = "#b4de78", shade = "#8cc060", deep = "#68a04c" })
