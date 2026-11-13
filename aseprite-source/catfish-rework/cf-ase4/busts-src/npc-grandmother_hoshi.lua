-- Grandmother Hoshi: grey mouse, silver bun with gold star hairpin, gold spectacles, plum jacket, red obi, maneki-neko
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-grandmother_hoshi")
local R = M.R
local fur = R("#aaa9b8", { hi = "#d8d6e2", shade = "#7a7a94", deep = "#444663" })
local silver = R("#d8d6e2", { hi = "#fffaf0", shade = "#a8a6bc", deep = "#6a6a88" })
local plum = R("#8a4a82", { hi = "#b87ab0", shade = "#5a3a6e", deep = "#3a2450" })
local red = R("#d8453f", { hi = "#ff8a6a", shade = "#a82a38", deep = "#6a1a2e" })
local calico = R("#fff4d6", { hi = "#fffaf0", shade = "#d8b89a", deep = "#8a6a5a" })
-- jacket (left over right collar)
local jacket = c:ellipse(39.5, 104, 35, 28):clip(c:rect(0, 72, 79, 99))
M.part(c, jacket, plum, { band = 2, pop = { x = 16, y = 84 } })
local collar = c:line({ { 28, 72 }, { 40, 84 }, { 56, 99 } }, 3):clip(jacket)
M.part(c, collar, { hi = plum.hi, base = plum.hi, shade = plum.base, deep = plum.deep, mid = plum.base }, { band = 1, nopop = true, inner = false })
c:stitch({ { 29, 74 }, { 41, 86 }, { 56, 99 } })
-- obi
local obi = c:rect(0, 92, 79, 99):clip(jacket)
M.part(c, obi, red, { band = 2, nopop = true })
c:hem(95, 4, 76)
-- ears (round, big)
for _, e in ipairs({ { 20, 36 }, { 59, 36 } }) do
  M.part(c, c:ellipse(e[1], e[2], 8, 8), fur, { band = 2, nopop = true })
  c:fillMask(c:ellipse(e[1] + (e[1] < 40 and 1 or -1), e[2] + 1, 5, 5), "#e8909e")
  c:fillMask(c:ellipse(e[1] + (e[1] < 40 and 0 or 0), e[2] + 2, 3, 3), "#c94f84")
end
-- head
local head = c:ellipse(39.5, 54, 19.5, 17)
M.part(c, head, fur, { band = 3 })
-- silver hair: bun + parted fringe
local bun = c:ellipse(39.5, 25, 8, 7)
M.part(c, bun, silver, { band = 2, pop = { x = 36, y = 22 } })
for _, p in ipairs({ { 33, 25 }, { 35, 28 }, { 41, 21 }, { 44, 24 }, { 38, 30 } }) do M.pts(c, { { p[1], p[2], silver.shade }, { p[1] + 1, p[2], silver.shade } }) end
local hair = head:copy():clip(c:rect(0, 0, 79, 45)):cut(c:ellipse(39.5, 52, 14, 12)):add(c:rect(33, 32, 46, 38))
M.part(c, hair, silver, { band = 2, nopop = true })
for _, s in ipairs({ { { 39, 33 }, { 32, 36 }, { 26, 41 }, { 23, 47 } }, { { 40, 33 }, { 47, 36 }, { 53, 41 }, { 56, 47 } }, { { 39, 35 }, { 34, 38 }, { 29, 43 } }, { { 40, 35 }, { 45, 38 }, { 50, 43 } } }) do
  c:line(s, 1):clip(hair):each(function(x, y) M.keep(c, x, y, silver.shade) end)
  c:line(s, 1):shift(0, -1):clip(hair):each(function(x, y) if c:get(x, y) == silver.base then M.keep(c, x, y, silver.hi) end end)
end
-- hairpin with gold star
local pin = c:line({ { 46, 27 }, { 55, 18 }, { 60, 13 } }, 1)
M.part(c, pin, P.gold, { flat = true, nopop = true, band = 1 })
M.part(c, c:poly({ { 60, 6 }, { 62, 10 }, { 66, 10 }, { 63, 13 }, { 64, 17 }, { 60, 14 }, { 56, 17 }, { 57, 13 }, { 54, 10 }, { 58, 10 } }), P.gold, { band = 1, pop = { x = 59, y = 9 } })
-- face: round gold spectacles
M.eyes(c, 30, 49, 44, 49)
for _, ex in ipairs({ 32, 46 }) do
  c:ellipse(ex, 51, 6, 5.5):cut(c:ellipse(ex, 51, 4, 3.6)):each(function(x, y) M.keep(c, x, y, "#f5b82e") end)
  M.pts(c, { { ex - 4, 48, "#ffe38a" }, { ex - 3, 47, "#ffe38a" }, { ex + 3, 55, "#d98322" } })
end
c:fillMask(c:rect(37, 50, 41, 50), "#f5b82e")
c:cheek(24, 57) c:cheek(54, 57)
-- designed nose: pink pointed mouse nose
c:paint({ "..hh..", ".pppp.", "ppppps", ".pppp.", "..ss.." }, 37, 56, { h = "#ffc4d8", p = "#f5809f", s = "#c94f84" })
M.pts(c, { { 38, 62 }, { 39, 63 }, { 40, 63 }, { 41, 62 } }, fur.deep)
for _, w in ipairs({ { 30, 60, 20, 58 }, { 30, 62, 20, 63 }, { 49, 60, 59, 58 }, { 49, 62, 59, 63 } }) do c:line({ { w[1], w[2] }, { w[3], w[4] } }, 1):each(function(x, y) if c:get(x, y) == fur.base or c:get(x, y) == fur.shade then M.keep(c, x, y, "#fff4d6") end end) end
-- maneki-neko calico, lower right, raised paw, red collar + gold bell
local body = c:ellipse(62, 90, 7, 8):clip(c:rect(0, 0, 79, 99))
M.part(c, c:poly({ { 56, 83 }, { 55, 76 }, { 61, 80 } }), calico, { band = 1, nopop = true }) M.part(c, c:poly({ { 68, 83 }, { 69, 76 }, { 63, 80 } }), calico, { band = 1, nopop = true })
M.part(c, body, calico, { band = 2, nopop = true })
M.part(c, c:ellipse(62, 85, 6, 5), calico, { band = 2, nopop = true })
M.part(c, c:rect(68, 78, 70, 87), calico, { band = 1, nopop = true })
M.pts(c, { { 59, 85, "#2b1c26" }, { 65, 85, "#2b1c26" }, { 62, 87, "#e8909e" }, { 58, 82, "#e8943a" }, { 59, 82, "#e8943a" }, { 66, 82, "#4a3a3e" }, { 65, 82, "#4a3a3e" } })
c:fillMask(c:rect(57, 89, 67, 90), red.base) M.pts(c, { { 62, 91 }, { 62, 92 } }, "#f5b82e")
M.fin(c, "npc-grandmother_hoshi", { base = "#f58eb0", shade = "#d86a98", deep = "#a8467a" })
