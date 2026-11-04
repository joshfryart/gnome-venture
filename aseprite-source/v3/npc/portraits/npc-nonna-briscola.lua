-- npc-nonna-briscola portrait (npc2 P1_25) species: sea otter
-- Elder sea-otter nonna, same design as the sprite: red polka-dot babushka knotted under the chin,
-- moss shawl + lace collar, grey brows and whiskers, holding up a fresh fish (prop). Sky-blue river disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nonna-briscola"
local FUR = { hi = "#d9a070", base = "#a86c44", shade = "#74463a", deep = "#4a2c34" }
local MUZ = { hi = P.cream, base = "#f0dcb4", shade = "#c9a99a", deep = "#8a6a78" }
local SCARF, SHAWL, FISH = P.ember, P.moss, P.sea
local LACE = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local DISC = { base = P.sky.base, shade = P.sky.shade, deep = P.sky.deep }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- shawl shoulders + gold stitch
local sh = c:ellipse(39.5, 108, 37, 32):clip(c:rect(0, 74, 79, 99))
c:part(sh, SHAWL, { band = 3 })
local st = {}
for x = 8, 72, 4 do st[#st + 1] = { x, math.floor(108 - 32 * math.sqrt(math.max(0, 1 - ((x - 39.5) / 37) ^ 2)) + 4.5) } end
c:stitch(st)
-- lace collar with scallop dots
c:part(c:ellipse(39.5, 74, 15, 4.5), LACE, { band = 1, nopop = true })
for x = 27, 52, 3 do c:put(x, 77, P.stone.hi) end
-- head
c:part(c:ellipse(39.5, 52, 20, 17), FUR, { band = 3 })
-- babushka
local scarf = c:ellipse(39.5, 51, 22.5, 19.5):clip(c:rect(0, 0, 79, 42))
scarf:add(c:poly{ { 16, 42 }, { 24, 42 }, { 23, 60 }, { 18, 57 } })
scarf:add(c:poly{ { 55, 42 }, { 63, 42 }, { 61, 57 }, { 56, 60 } })
scarf:add(c:line({ { 20, 58 }, { 34, 71 } }, 3))
scarf:add(c:line({ { 59, 58 }, { 45, 71 } }, 3))
scarf:add(c:ellipse(39.5, 72, 3.5, 2.5))
scarf:add(c:poly{ { 37, 73 }, { 32, 82 }, { 36, 82 } })
scarf:add(c:poly{ { 42, 73 }, { 47, 82 }, { 43, 82 } })
c:part(scarf, SCARF, { band = 2, pop = { x = 24, y = 36 } })
local inner = scarf:shrink(1)
local r = 0
for y = 33, 80, 5 do
  for x = 14 + (r % 2) * 3, 64, 6 do
    if inner:has(x, y) and inner:has(x + 1, y + 1) then c:fillMask(c:rect(x, y, x + 1, y + 1), P.cream) end
  end
  r = r + 1
end
c:part(c:ellipse(39.5, 72, 2, 1.5), SCARF, { band = 1, nopop = true })
-- fish (prop) held up across the chest
local fish = c:ellipse(38, 88, 15, 5.5)
fish:add(c:poly{ { 51, 88 }, { 60, 82 }, { 57, 88 }, { 60, 94 } })
c:part(fish, FISH, { band = 2, pop = { x = 30, y = 84 } })
c:part(c:poly{ { 36, 83 }, { 41, 79 }, { 45, 83 } }, FISH, { band = 1, nopop = true })
for x = 25, 50 do if fish:has(x, 91) then c:put(x, 91, FISH.hi) end end
for _, q in ipairs{ { 32, 86 }, { 37, 85 }, { 42, 86 }, { 47, 87 } } do c:put(q[1], q[2], P.gold.base) c:put(q[1] + 1, q[2], P.gold.hi) end
for y = 85, 91 do c:put(29 - ((y == 85 or y == 91) and 0 or 1), y, FISH.deep) end
c:paint({ ".c.", "cic", ".c." }, 25, 85, { c = "cream", i = "ink" })
c:put(23, 89, P.ink) c:put(24, 89, P.ink)
-- paws under the fish
for _, x in ipairs{ 30, 47 } do
  c:part(c:ellipse(x, 94, 4, 3), FUR, { band = 1, pop = { x = x - 2, y = 92 } })
  c:put(x - 1, 92, FUR.deep) c:put(x + 1, 92, FUR.deep)
end
-- muzzle
c:part(c:ellipse(39.5, 58, 11, 7.5), MUZ, { band = 2, nopop = true })
-- otter nose
c:paint({ ".LhNNNN.", "LLNNNNNN", ".NNNNNN.", "..NNNN..", "...NN..." }, 36, 52,
  { L = FUR.shade, N = "#5a3440", h = "cream" })
-- mouth
c:paint({ ".....ii.....", "i...i..i...i", ".iii....iii." }, 34, 57, { i = "ink" })
-- whisker dots + grey whiskers
for _, q in ipairs{ { 31, 57 }, { 33, 60 }, { 31, 62 }, { 48, 57 }, { 46, 60 }, { 48, 62 } } do c:put(q[1], q[2], MUZ.shade) end
c:fillMask(c:line({ { 28, 61 }, { 24, 63 } }, 1), P.stone.hi)
c:fillMask(c:line({ { 51, 61 }, { 55, 63 } }, 1), P.stone.hi)
c:paint({ "PPP", "PhP" }, 23, 52, { P = "petal.base", h = "petal.hi" })
c:paint({ "PPP", "PhP" }, 54, 52, { P = "petal.base", h = "petal.hi" })
-- grey brows + locked eyes
c:paint({ "Bhhhhh" }, 26, 43, { B = "stone.base", h = "stone.hi" })
c:paint({ "hhhhhB" }, 48, 43, { B = "stone.base", h = "stone.hi" })
c:eyeLocked(27, 45) c:eyeLocked(48, 45)
c:finish{ outline = true }
backdrop(DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
