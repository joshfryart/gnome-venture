-- Abuela Quilla: llama grandmother, brown felt hat with pencil, silver braids, striped shawl, blue felt fish toy
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(DIR .. "/../banners/bust.lua")
local HP, P = M.HP, M.P
local c = M.new("npc-abuela_quilla")
local R = M.R
local fur = R("#d4a874", { hi = "#f2d4a0", shade = "#a8764c", deep = "#6a4030" })
local muz = R("#f2dcb4", { hi = "#fff4d6", shade = "#c8946c", deep = "#7a4a3a" })
local hat = R("#6e4a34", { hi = "#a07a58", shade = "#4a3030", deep = "#2e1e24" })
local red = R("#d8453f", { hi = "#ff8a6a", shade = "#a82a38", deep = "#6a1a2e" })
local grey = R("#a8a8b8", { hi = "#e2e0e6", shade = "#74758c", deep = "#444663" })
local blue = R("#4f8fd8", { hi = "#a8d4ff", shade = "#3a5ab0", deep = "#2a3a7a" })
-- shawl: red base with gold zigzag + sea stripe
local shawl = c:ellipse(39.5, 104, 38, 30):clip(c:rect(0, 72, 79, 99))
M.part(c, shawl, red, { band = 2, pop = { x = 14, y = 84 } })
shawl:copy():clip(c:rect(0, 82, 79, 82)):each(function(x, y) M.keep(c, x, y, "#f5cf6a") end)
for x = 0, 79 do local t = (x + 1) % 6 local d = t < 3 and t or 6 - t if shawl:has(x, 86 + d) then M.keep(c, x, 86 + d, "#fff4d6") end end
for x = 3, 79, 6 do for _, p in ipairs({ { x, 90 }, { x - 1, 91 }, { x + 1, 91 }, { x, 92 } }) do if shawl:has(p[1], p[2]) then M.keep(c, p[1], p[2], "#f5cf6a") end end end
shawl:copy():clip(c:rect(0, 95, 79, 96)):each(function(x, y) M.keep(c, x, y, "#5fc4c8") end)
-- neck
local neck = c:rect(32, 66, 47, 76)
M.part(c, neck, fur, { band = 2, nopop = true })
M.part(c, c:ellipse(39.5, 74, 11, 3), muz, { band = 1, nopop = true })  -- collar fluff
-- ears (tall), behind head
for _, e in ipairs({ { { 23, 44 }, { 20, 18 }, { 31, 38 } }, { { 56, 44 }, { 59, 18 }, { 48, 38 } } }) do
  local ear = c:poly({ e[1], e[2], e[3] })
  M.part(c, ear, fur, { band = 1, nopop = true })
  c:fillMask(c:poly({ { e[1][1] + (e[2][1] > 39 and -1 or 2), e[1][2] - 2 }, { e[2][1], e[2][2] + 5 }, { e[3][1] + (e[2][1] > 39 and 1 or -2), e[3][2] } }), "#e8a89a")
end
-- braids (grey) with red ties
for _, b in ipairs({ { 19, 52, 80, -2 }, { 60, 52, 80, 2 } }) do
  local i = 0
  for y = b[2], b[3], 4 do
    local x = b[1] + math.floor((y - b[2]) * b[4] / (b[3] - b[2]) + .5) + ((i % 2 == 0) and 0 or 1)
    M.part(c, c:ellipse(x, y, 3, 2.6), (i % 2 == 0) and grey or { hi = grey.hi, base = grey.shade, shade = grey.deep, deep = grey.deep, mid = grey.deep }, { band = 1, nopop = true })
    M.pts(c, { { x - 2, y - 1, grey.hi } })
    i = i + 1
  end
  c:fillMask(c:rect(b[1] + b[4] - 2, b[3] + 3, b[1] + b[4] + 2, b[3] + 4), red.base)
end
-- head + long muzzle
local head = c:ellipse(39.5, 51, 19.5, 17)
M.part(c, head, fur, { band = 3 })
M.ticks(c, head:copy():clip(c:rect(0, 0, 79, 42)), fur.hi, 6, 2)
local snout = c:ellipse(39.5, 60, 11, 8.5)
M.part(c, snout, muz, { band = 2, nopop = true })
-- designed nose: split lip + dark nostril pair
c:paint({ "..hh..hh..", ".nnnnnnnn.", "..nnn.nnn.", "....ss...." }, 35, 55, { h = "#8a6860", n = "#5a3a38", s = muz.deep })
M.pts(c, { { 36, 56 }, { 37, 56 } }, "#8a6860")
M.pts(c, { { 36, 63 }, { 37, 64 }, { 38, 64 }, { 39, 63 }, { 40, 63 }, { 41, 64 }, { 42, 64 }, { 43, 63 } }, muz.deep)
M.eyes(c, 29, 44, 45, 44)
M.pts(c, { { 28, 42 }, { 29, 41 }, { 30, 41 }, { 31, 41 }, { 47, 41 }, { 48, 41 }, { 49, 41 }, { 50, 42 } }, fur.deep)
c:cheek(24, 54) c:cheek(53, 54)
-- hat: crown, red band + pencil, brim
local crown = c:ellipse(39.5, 24, 11, 9):clip(c:rect(0, 0, 79, 30)):add(c:rect(29, 24, 50, 31))
M.part(c, crown, hat, { band = 2 })
c:fillMask(c:rect(29, 25, 50, 28), red.base) c:fillMask(c:rect(29, 28, 50, 28), red.shade) c:stitch({ { 30, 26 }, { 50, 26 } })
local brim = c:ellipse(39.5, 33, 18, 3.4)
M.part(c, brim, hat, { band = 1, pop = { x = 26, y = 31 } })
M.pts(c, { { 31, 35 }, { 39, 36 }, { 47, 35 } }, hat.deep)
local pencil = c:line({ { 48, 28 }, { 54, 16 }, { 58, 8 } }, 2)
M.part(c, pencil, P.gold, { band = 1, nopop = true })
c:fillMask(c:rect(57, 5, 59, 7), red.base) M.pts(c, { { 56, 11 }, { 55, 13 } }, P.gold.hi)
-- blue felt fish toy dangling from her hoof at lower right
c:line({ { 61, 78 }, { 61, 84 } }, 1):each(function(x, y) M.keep(c, x, y, P.wood.shade) end)
local fish = c:ellipse(60, 90, 6, 3.4):add(c:poly({ { 65, 90 }, { 70, 86 }, { 70, 94 } }))
M.part(c, fish, blue, { band = 1, pop = { x = 56, y = 88 } })
M.pts(c, { { 56, 89, "#2b1c26" }, { 59, 90, blue.shade }, { 62, 90, blue.shade } })
M.fin(c, "npc-abuela_quilla", { base = "#8a6fd0", shade = "#6a52b0", deep = "#4a3a88" })
