-- Old Baobab Kito: elephant grandfather, cream embroidered kofia cap, striped cloth + gold button, kitten in a woven basket
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-old_baobab_kito")
local R = M.R
local fur = R("#9a9ab4", { hi = "#c8c8dc", shade = "#6a6a8c", deep = "#444663" })
local cap = R("#f4e6c8", { hi = "#fff8e6", shade = "#cfae8a", deep = "#8a6a5a" })
local tusk = R("#fff0d4", { hi = "#fff8e8", shade = "#d8b896", deep = "#8a6a5a" })
local basket = R("#d8a458", { hi = "#f8d488", shade = "#a8742e", deep = "#6a4422" })
local ginger = R("#ee9040", { hi = "#ffd08a", shade = "#c4602a", deep = "#7a3a1c" })
-- cloth: striped, over one shoulder
local cloth = c:ellipse(39.5, 104, 37, 29):clip(c:rect(0, 74, 79, 99))
M.part(c, cloth, P.ember, { band = 2, pop = { x = 14, y = 86 } })
local cols = { P.gold.base, P.moss.base, "#fff4d6", P.ember.base }
for x = 0, 79 do local col = cols[1 + math.floor(x / 5) % 4] for y = 76, 99 do if cloth:has(x, y) and (y % 12 < 4 or x % 10 < 3) then if c:get(x, y) ~= P.ember.shade then M.keep(c, x, y, col) end end end end
cloth:copy():clip(c:rect(0, 80, 79, 80)):each(function(x, y) M.keep(c, x, y, P.gold.shade) end)
c:button(27, 84)
-- big ears behind head
for _, e in ipairs({ { 14, 52, -1 }, { 65, 52, 1 } }) do
  M.part(c, c:ellipse(e[1], e[2], 11, 14), fur, { band = 2, nopop = true })
  c:fillMask(c:ellipse(e[1] - e[3] * -1 * 0 + (e[3] > 0 and -1 or 1), e[2] + 1, 7, 10), "#d8a0a8")
  c:fillMask(c:ellipse(e[1] + (e[3] > 0 and 0 or 0), e[2] + 4, 5, 6), "#c98a98")
  M.pts(c, { { e[1] - 4, e[2] - 6, "#e8bcc0" }, { e[1] - 3, e[2] - 7, "#e8bcc0" } })
end
-- head
local head = c:ellipse(39.5, 52, 19.5, 17)
M.part(c, head, fur, { band = 3 })
-- wrinkles
M.pts(c, { { 26, 44 }, { 27, 45 }, { 28, 45 }, { 52, 45 }, { 51, 45 }, { 52, 44 }, { 33, 41 }, { 34, 41 }, { 45, 41 }, { 46, 41 } }, fur.shade)
-- trunk: segmented, curling at tip, tusks flanking
local trunk = c:poly({ { 33, 52 }, { 46, 52 }, { 45, 66 }, { 47, 76 }, { 43, 82 }, { 37, 80 }, { 39, 74 }, { 36, 66 } })
M.part(c, trunk, fur, { band = 2, nopop = true })
for y = 56, 78, 3 do trunk:copy():clip(c:rect(0, y, 79, y)):each(function(x, yy) M.keep(c, x, yy, fur.shade) end) end
M.pts(c, { { 36, 54 }, { 36, 56 }, { 37, 59 }, { 38, 63 } }, fur.hi)
c:fillMask(c:rect(40, 80, 42, 81), "#d8a0a8")
for _, s in ipairs({ -1, 1 }) do
  local t = c:poly({ { 39.5 + s * 7, 62 }, { 39.5 + s * 12, 66 }, { 39.5 + s * 11, 73 }, { 39.5 + s * 8, 67 } })
  M.part(c, t, tusk, { band = 1, nopop = true })
end
-- brows white, eyes
M.eyes(c, 28, 46, 46, 46)
M.pts(c, { { 27, 43 }, { 28, 42 }, { 29, 42 }, { 30, 42 }, { 31, 43 }, { 47, 43 }, { 48, 42 }, { 49, 42 }, { 50, 42 }, { 51, 43 } }, "#e2e0e6")
c:cheek(24, 56) c:cheek(54, 56)
-- kofia cap
local kofia = c:rrect(26, 22, 53, 37, 4)
M.part(c, kofia, cap, { band = 2, pop = { x = 31, y = 25 } })
for x = 27, 52 do if (x % 3 == 0) then M.keep(c, x, 33, "#f5b82e") M.keep(c, x + 1, 34, P.ember.base) end end
for x = 28, 50, 4 do M.pts(c, { { x, 27, P.sea.base }, { x + 1, 28, P.sea.base }, { x, 29, P.sea.base }, { x - 1, 28, P.sea.base } }) end
c:fillMask(c:rect(26, 36, 53, 37), cap.shade)
-- woven basket + tabby kitten
local kit = c:ellipse(60, 85, 6.5, 5.5)
M.part(c, c:poly({ { 55, 83 }, { 55, 77 }, { 59, 81 } }), ginger, { band = 1, nopop = true }) M.part(c, c:poly({ { 66, 83 }, { 66, 77 }, { 62, 81 } }), ginger, { band = 1, nopop = true })
M.part(c, kit, ginger, { band = 2, pop = { x = 56, y = 82 } })
M.pts(c, { { 57, 84, "#2b1c26" }, { 63, 84, "#2b1c26" }, { 60, 87, "#e8909e" }, { 59, 81, ginger.shade }, { 61, 81, ginger.shade } })
local bk = c:rrect(46, 88, 76, 99, 3)
M.part(c, bk, basket, { band = 2, pop = { x = 50, y = 90 } })
for x = 48, 74, 4 do M.pts(c, { { x, 91, basket.deep }, { x + 2, 93, basket.deep }, { x, 95, basket.deep }, { x + 2, 97, basket.deep } }) end
c:rect(46, 88, 76, 89):each(function(x, y) M.keep(c, x, y, basket.hi) end)
M.fin(c, "npc-old_baobab_kito", { base = "#f6b052", shade = "#e08a38", deep = "#b8602a" })
