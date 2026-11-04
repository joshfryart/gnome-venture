-- npc-juniper-seedwell portrait (npc2 P1_17) species: bumblebee
-- Same design as the sprite: green leaf hood with curled tip and midrib, antennae through the hood,
-- striped gold face, glassy wings, leaf-hem cape; holds up a burlap seed sack with a bean sprout. Leaf-pale disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-juniper-seedwell"
local LEAF = P.moss
local CAPE = { hi = LEAF.hi, base = LEAF.base, shade = LEAF.shade, deep = LEAF.deep }
local FUZ = P.gold
local STR = { hi = P.dusk.shade, base = P.dusk.deep, shade = "#2a1f45", deep = "#2a1f45" }
local WING = { hi = P.cream, base = P.sky.hi, shade = P.sky.base, deep = P.sky.shade }
local NOSEB = { hi = P.gold.hi, base = P.gold.shade, shade = P.gold.deep, deep = P.gold.deep }
local BG = { base = "#d8eca0", shade = "#a9d070", deep = "#6fa04e" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function stripe(m, y0, y1, zig)
  local map = { [FUZ.hi:lower()] = STR.hi, [FUZ.base:lower()] = STR.base, [FUZ.shade:lower()] = STR.shade, [FUZ.deep:lower()] = STR.deep }
  m:each(function(x, y)
    local z = zig and (x % 2) or 0
    if y >= y0 + z and y <= y1 - z then local v = map[c:get(x, y) or ""] if v then keep(x, y, v) end end end)
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade:lower() then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
for _, s in ipairs{ -1, 1 } do
  local w = c:ellipse(39.5 + s * 25, 66, 7, 11)
  c:part(w, WING, { band = 2, nopop = true })
  c:fillMask(c:line({ { 39.5 + s * 22, 74 }, { 39.5 + s * 26, 58 } }, 1):clip(w:shrink(1)), P.sky.base)
  c:fillMask(c:line({ { 39.5 + s * 25, 66 }, { 39.5 + s * 30, 62 } }, 1):clip(w:shrink(1)), P.sky.base)
end
local body = c:ellipse(39.5, 108, 30, 27):clip(c:rect(0, 0, 79, 99))
c:part(body, FUZ, { band = 3, pop = { x = 16, y = 90 } })
stripe(body, 87, 91, true) stripe(body, 96, 99, true)
local cape = c:ellipse(39.5, 78, 25, 6)
for _, x in ipairs{ 18, 25, 32, 39.5, 47, 54, 61 } do cape:add(HP.poly{ { x - 4, 82 }, { x, 88 }, { x + 4, 82 } }) end
c:part(cape, CAPE, { band = 2, pop = { x = 22, y = 75 } })
for _, x in ipairs{ 18, 25, 32, 47, 54, 61 } do for y = 82, 86 do keep(math.floor(x + .5), y, LEAF.shade) end end
-- seed sack with bean sprout, held at the left
c:part(c:line({ { 17, 79 }, { 17, 73 } }, 1), LEAF, { noshade = true, nopop = true })
c:part(c:ellipse(13.5, 71, 3.5, 2), LEAF, { band = 1, pop = { x = 12, y = 70 } })
c:part(c:ellipse(20.5, 70, 3.5, 2), LEAF, { band = 1, pop = { x = 19, y = 69 } })
c:part(c:rrect(14, 79, 20, 83, 1), P.wood, { band = 1, nopop = true })
c:part(c:ellipse(17, 90, 8, 7), P.wood, { band = 2, pop = { x = 12, y = 86 }, sep = true })
for y = 85, 96, 2 do for x = 10, 24, 3 do if c:get(x + (y % 4 == 1 and 1 or 0), y) == P.wood.base:lower() then keep(x + (y % 4 == 1 and 1 or 0), y, P.wood.shade) end end end
c:stitch{ { 14, 83 }, { 20, 83 } }
c:part(c:ellipse(23, 82, 3, 3), STR, { band = 1, pop = { x = 22, y = 81 } })
-- hood
local hood = c:ellipse(39.5, 45, 21, 20)
hood:add(c:line({ { 39.5, 27 }, { 40, 19 }, { 42, 15 } }, 4))
hood:add(c:line({ { 42, 15 }, { 45, 12 }, { 48, 12 } }, 2))
c:part(hood, LEAF, { band = 3, pop = { x = 27, y = 32 } })
c:fillMask(c:line({ { 39.5, 38 }, { 39.5, 26 }, { 40, 19 }, { 42, 15 } }, 1):clip(hood:shrink(1)), LEAF.shade)
for _, v in ipairs{ { {39,33},{31,29} }, { {40,33},{48,29} }, { {39,29},{33,25} }, { {40,29},{46,25} } } do
  c:fillMask(c:line(v, 1):clip(hood:shrink(1)), LEAF.shade) end
local face = c:ellipse(39.5, 51, 15, 13)
c:part(face, FUZ, { band = 2, pop = { x = 28, y = 45 } })
stripe(face, 39, 42, true) stripe(face, 60, 64, true)
c:eyeLocked(30, 46) c:eyeLocked(45, 46)
c:part(c:ellipse(39.5, 53.5, 2.5, 2), NOSEB, { band = 1, pop = { x = 38, y = 52 } })
c:paint({ "i......i", ".iiiiii." }, 36, 56, { i = "ink" })
c:paint({ "PPP" }, 26, 54, { P = "petal.base" }) c:paint({ "PPP" }, 51, 54, { P = "petal.base" })
c:part(c:ellipse(21, 15, 3, 3), STR, { band = 1, pop = { x = 19, y = 13 } })
c:part(c:ellipse(59, 17, 3, 3), STR, { band = 1, pop = { x = 57, y = 15 } })
c:finish{ outline = true }
c:fillMask(c:line({ { 30, 27 }, { 26, 21 }, { 23, 18 } }, 1), P.ink)
c:fillMask(c:line({ { 50, 28 }, { 54, 23 }, { 57, 20 } }, 1), P.ink)
backdrop(BG)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
