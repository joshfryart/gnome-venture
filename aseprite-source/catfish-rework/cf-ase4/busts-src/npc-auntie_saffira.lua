-- Auntie Saffira: grey tabby cat auntie, saffron hood with ears through, teal kaftan, cat-silhouette brass lantern
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-auntie_saffira")
local R = M.R
local fur = R("#9a9aa8", { hi = "#c8c8d4", shade = "#6a6a84", deep = "#444663" })
local saf = R("#f5b82e", { hi = "#ffe38a", shade = "#d98322", deep = "#8f4a1f" })
local teal = R("#2fa8a8", { hi = "#7ae0d0", shade = "#2a7a98", deep = "#1f4a6e" })
local brass = R("#d9a53a", { hi = "#ffe38a", shade = "#a8702a", deep = "#5e3a22" })
-- kaftan
local kaftan = c:ellipse(39.5, 104, 35, 28):clip(c:rect(0, 72, 79, 99))
M.part(c, kaftan, teal, { band = 2, pop = { x = 16, y = 84 } })
c:line({ { 39, 80 }, { 39, 99 } }, 1):each(function(x, y) M.keep(c, x, y, teal.deep) end)
c:stitch({ { 36, 82 }, { 36, 99 } }) c:stitch({ { 42, 82 }, { 42, 99 } })
for y = 86, 96, 5 do for _, x in ipairs({ 22, 56 }) do M.pts(c, { { x, y, "#f5b82e" }, { x + 1, y + 1, "#f5b82e" }, { x - 1, y + 1, "#f5b82e" }, { x, y + 2, "#f5b82e" } }) end end
-- hood: saffron cowl, rolled collar
local hood = c:ellipse(39.5, 50, 25, 24):clip(c:rect(0, 20, 79, 73))
M.part(c, hood, saf, { band = 3, pop = { x = 22, y = 34 } })
local roll = c:ellipse(39.5, 76, 24, 6)
M.part(c, roll, saf, { band = 2, nopop = true })
M.pts(c, { { 24, 76 }, { 31, 79 }, { 40, 80 }, { 49, 79 }, { 56, 76 } }, saf.deep)
M.pts(c, { { 30, 73 }, { 36, 74 }, { 45, 74 }, { 51, 73 } }, saf.hi)
-- ears poking out of the hood at top
for _, e in ipairs({ { { 22, 36 }, { 19, 12 }, { 36, 28 } }, { { 57, 36 }, { 60, 12 }, { 43, 28 } } }) do
  M.part(c, c:poly({ e[1], e[2], e[3] }), fur, { band = 1, nopop = true })
  c:fillMask(c:poly({ { e[1][1] + (e[2][1] > 39 and -2 or 3), e[1][2] - 2 }, { e[2][1], e[2][2] + 6 }, { e[3][1] + (e[2][1] > 39 and 2 or -2), e[3][2] + 1 } }), "#e8909e")
end
-- face
local head = c:ellipse(39.5, 54, 19.5, 16)
M.part(c, head, fur, { band = 3 })
-- hood opening trim over the head edge
head:copy():cut(head:copy():shrink(1)):clip(c:rect(0, 0, 79, 44)):each(function(x, y) M.keep(c, x, y, saf.shade) end)
-- tabby forehead M + cheek stripes
M.pts(c, { { 34, 42 }, { 34, 43 }, { 37, 41 }, { 37, 42 }, { 39, 40 }, { 39, 41 }, { 42, 41 }, { 42, 42 }, { 45, 42 }, { 45, 43 } }, fur.deep)
M.pts(c, { { 21, 52 }, { 22, 53 }, { 23, 54 }, { 57, 52 }, { 56, 53 }, { 55, 54 }, { 21, 58 }, { 22, 59 }, { 58, 58 }, { 57, 59 } }, fur.deep)
M.eyes(c, 30, 47, 44, 47)
c:cheek(25, 56) c:cheek(53, 56)
-- muzzle + designed nose (pink triangle w/ lit top)
M.part(c, c:ellipse(39.5, 60, 8, 5), { hi = "#fff4d6", base = "#e8e0d8", shade = "#c0b4b8", deep = "#8a7a8a", mid = "#d4c8c8" }, { band = 1, nopop = true })
c:paint({ ".hhhh.", "pppppp", ".pppp.", "..ss.." }, 37, 55, { h = "#ffc4d8", p = "#f5809f", s = "#c94f84" })
M.pts(c, { { 39, 59 }, { 40, 59 }, { 38, 60 }, { 37, 61 }, { 41, 60 }, { 42, 61 } }, fur.deep)
for _, w in ipairs({ { 30, 58, 22, 56 }, { 30, 60, 22, 61 }, { 49, 58, 57, 56 }, { 49, 60, 57, 61 } }) do c:line({ { w[1], w[2] }, { w[3], w[4] } }, 1):each(function(x, y) if not c:get(x, y) or c:get(x, y) == fur.base then M.keep(c, x, y, "#fff4d6") end end) end
-- lantern at lower left: brass body, cat silhouette on the glowing glass
local lan = c:rrect(5, 83, 20, 99, 2)
M.part(c, lan, brass, { band = 1, nopop = true })
c:fillMask(c:rect(8, 86, 17, 97), "#ffe08a") c:fillMask(c:rect(8, 86, 17, 87), "#fff4d6")
c:fillMask(c:ellipse(12.5, 93, 3, 2.6), "#5e3a22") c:fillMask(c:poly({ { 10, 91 }, { 10, 88 }, { 12, 90 } }), "#5e3a22") c:fillMask(c:poly({ { 15, 91 }, { 15, 88 }, { 13, 90 } }), "#5e3a22")
M.part(c, c:rect(7, 80, 18, 82), brass, { band = 1, nopop = true })
M.part(c, c:ellipse(12.5, 78, 4, 3), brass, { band = 1, nopop = true })
M.pts(c, { { 12, 76 }, { 13, 76 } }, brass.deep)
-- paw holding it
M.part(c, c:ellipse(24, 91, 5, 4), fur, { band = 1, nopop = true })
M.fin(c, "npc-auntie_saffira", { base = "#c4b0ee", shade = "#a48cd8", deep = "#7a62b8" })
