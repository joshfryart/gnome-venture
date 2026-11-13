-- Auntie Mossbead: green tortoise auntie, purple gele with fan, gold discs, moss bead string, kente top, calabash + grey kitten
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-auntie_mossbead")
local R = M.R
local skin = R("#7cb84a", { hi = "#b4e080", shade = "#4a8a4a", deep = "#2a5a44" })
local shell = R("#a8743e", { hi = "#d8a468", shade = "#7a4a30", deep = "#4a2e2c" })
local gele = R("#8a6ad0", { hi = "#b8a0f0", shade = "#5a459e", deep = "#35295f" })
local beak = R("#e8c878", { hi = "#fff0b0", shade = "#b88a4a", deep = "#6a4a2a" })
local grey = R("#9a9aa8", { hi = "#c8c8d4", shade = "#6a6a84", deep = "#444663" })
local calab = R("#b8742e", { hi = "#e8a85a", shade = "#8a4a28", deep = "#4a2a22" })
-- shell behind shoulders
local sh = c:ellipse(39.5, 98, 38, 26):clip(c:rect(0, 70, 79, 99))
M.part(c, sh, shell, { band = 2, nopop = true })
for _, l in ipairs({ { { 12, 99 }, { 16, 84 }, { 24, 76 } }, { { 67, 99 }, { 63, 84 }, { 55, 76 } }, { { 4, 92 }, { 16, 84 } }, { { 75, 92 }, { 63, 84 } } }) do c:line(l, 1):clip(sh):each(function(x, y) M.keep(c, x, y, shell.deep) end) end
-- kente top: gold/green/red blocks
local top = c:ellipse(39.5, 106, 29, 27):clip(c:rect(0, 78, 79, 99))
M.part(c, top, P.gold, { band = 2, pop = { x = 24, y = 88 } })
for x = 10, 70 do
  local k = math.floor((x - 10) / 6) % 4
  for y = 90, 98 do if top:has(x, y) then
    local col = (k == 0 and P.moss.base) or (k == 1 and P.ember.base) or (k == 2 and P.gold.base) or "#4a3a7a"
    if (y - 90) % 4 == 3 then col = P.gold.deep end
    M.keep(c, x, y, col) end end
end
for x = 10, 70, 6 do for y = 80, 88 do if top:has(x, y) then M.keep(c, x, y, ((y - 80) % 4 == 3) and P.gold.deep or P.gold.shade) end end end
-- neck + head (tortoise)
M.part(c, c:rect(31, 68, 48, 78), skin, { band = 2, nopop = true })
local head = c:ellipse(39.5, 54, 19.5, 16)
M.part(c, head, skin, { band = 3 })
M.pts(c, { { 24, 58 }, { 25, 60 }, { 54, 58 }, { 53, 60 }, { 33, 64 }, { 46, 64 } }, skin.shade)
-- gele: tall wrapped headtie with pleated fan on the right
local wrap = c:ellipse(39.5, 40, 22, 11):clip(c:rect(0, 0, 79, 46)):add(c:rrect(17, 40, 62, 45, 2))
M.part(c, wrap, gele, { band = 2, pop = { x = 28, y = 33 } })
for x = 20, 60, 4 do M.pts(c, { { x, 41, gele.shade }, { x + 1, 42, gele.shade } }) end
for y = 34, 44, 5 do wrap:copy():clip(c:rect(0, y, 79, y)):each(function(x, yy) if (x + yy) % 3 == 0 then M.keep(c, x, yy, "#f5cf6a") end end) end
local fan = c:poly({ { 44, 34 }, { 40, 18 }, { 50, 10 }, { 62, 16 }, { 66, 28 }, { 58, 38 } })
M.part(c, fan, gele, { band = 2, nopop = true })
for i = 0, 5 do c:line({ { 46 + i, 36 }, { 44 + i * 4, 14 + i } }, 1):clip(fan):each(function(x, y) M.keep(c, x, y, i % 2 == 0 and gele.shade or gele.hi) end) end
M.pts(c, { { 50, 22 }, { 55, 20 }, { 58, 26 }, { 47, 28 }, { 53, 30 } }, "#ffe38a")
-- gold disc earrings
for _, e in ipairs({ { 19, 57 }, { 60, 57 } }) do M.part(c, c:ellipse(e[1], e[2], 3, 3), P.gold, { band = 1, nopop = true }) end
-- eyes + cheeks
M.eyes(c, 30, 49, 44, 49)
M.pts(c, { { 29, 47 }, { 30, 46 }, { 31, 46 }, { 32, 46 }, { 46, 46 }, { 47, 46 }, { 48, 46 }, { 49, 47 } }, skin.deep)
c:cheek(24, 56) c:cheek(53, 56)
-- beak: designed nose (small blunt hooked bill with nostrils)
c:paint({ "..wwwwww..", ".whhhhwwm.", ".wwwwwwmm.", "..wwwwmm..", "...mmmm..." }, 34, 54, { w = beak.base, h = beak.hi, m = beak.shade })
M.pts(c, { { 37, 55 }, { 42, 55 } }, beak.deep)
M.pts(c, { { 35, 60 }, { 36, 61 }, { 37, 61 }, { 38, 61 }, { 39, 61 }, { 40, 61 }, { 41, 61 }, { 42, 61 }, { 43, 61 }, { 44, 60 } }, skin.deep)
-- moss-bead string (swag across chest) with fruit beads
local beads = c:line({ { 18, 72 }, { 24, 80 }, { 32, 85 }, { 39, 87 }, { 46, 85 }, { 54, 80 }, { 60, 72 } }, 3)
beads:each(function(x, y) M.keep(c, x, y, ((x + y) % 4 < 2) and P.moss.base or P.moss.shade) end)
for _, p in ipairs({ { 24, 79 }, { 39, 86 }, { 54, 79 } }) do c:fillMask(c:ellipse(p[1], p[2], 2.4, 2.4), P.ember.base) M.pts(c, { { p[1] - 1, p[2] - 1, P.ember.hi } }) end
-- calabash + grey kitten
local kit = c:ellipse(39.5, 88, 8, 6)
M.part(c, c:poly({ { 33, 85 }, { 33, 79 }, { 38, 83 } }), grey, { band = 1, nopop = true }) M.part(c, c:poly({ { 46, 85 }, { 46, 79 }, { 41, 83 } }), grey, { band = 1, nopop = true })
M.part(c, kit, grey, { band = 2, pop = { x = 34, y = 85 } })
M.pts(c, { { 36, 87, "#2b1c26" }, { 43, 87, "#2b1c26" }, { 39, 90, "#e8909e" }, { 40, 90, "#e8909e" }, { 38, 85, grey.deep }, { 40, 85, grey.deep }, { 42, 85, grey.deep } })
local bowl = c:ellipse(39.5, 94, 17, 8):clip(c:rect(0, 91, 79, 99))
M.part(c, bowl, calab, { band = 2, pop = { x = 27, y = 94 } })
c:rect(23, 91, 56, 92):clip(bowl):each(function(x, y) M.keep(c, x, y, calab.hi) end)
for x = 25, 54, 5 do M.pts(c, { { x, 95, calab.deep }, { x + 1, 96, calab.deep }, { x + 2, 95, calab.deep } }) end
M.part(c, c:ellipse(20, 91, 4.6, 3.6), skin, { band = 1, nopop = true }) M.part(c, c:ellipse(59, 91, 4.6, 3.6), skin, { band = 1, nopop = true })
M.fin(c, "npc-auntie_mossbead", { base = "#8ad0a0", shade = "#62b080", deep = "#3e8a62" })
