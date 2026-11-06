-- npc-old-twigg portrait (npc2 P1_27) species: stick insect
-- Elder walking-stick insect, almond seed-bark face with a twig-knot nose, curled antennae, stitched purple
-- hood-shawl, pink dress; prop: her twig cane sprouting two leaves. 80x100, amber disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-old-twigg"
local BARK = { hi = "#c99c6c", base = "#9a6e48", shade = "#6e4a44", deep = "#4a3040" }
local HOOD = { hi = "#a98ae0", base = "#7f5cc4", shade = "#5c4196", deep = "#3f2c6a" }
local SKIRT = { hi = "#f29ab0", base = "#d9668a", shade = "#a8496e", deep = "#713452" }
local GOLDR = { hi = "#ffe08a", base = "#f0b43c", shade = "#c47e2a", deep = "#8a4e26" }
local LEAF = { hi = "#c4e47a", base = "#7cba48", shade = "#4f8a4e", deep = "#33594a" }
local DISC = { hi = "#f8dc9c", base = "#e8b866", shade = "#c9904a", deep = "#9a6638" }
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:copy():grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local body = c:ellipse(39.5, 112, 33, 32):clip(c:rect(0, 0, 79, 99))
c:part(body, SKIRT, { band = 3, pop = { x = 14, y = 88 } })
local sh = c:poly{ { 11, 92 }, { 16, 73 }, { 27, 64 }, { 52, 64 }, { 63, 73 }, { 68, 92 }, { 54, 88 }, { 39.5, 96 }, { 25, 88 } }
local hood = c:ellipse(39.5, 44, 22, 24)
sh:add(hood)
c:part(sh, HOOD, { band = 3, pop = { x = 26, y = 26 } })
c:fillMask(c:line({ { 24, 70 }, { 20, 86 } }, 1):clip(sh), HOOD.shade)
c:fillMask(c:line({ { 31, 72 }, { 30, 88 } }, 1):clip(sh), HOOD.shade)
c:fillMask(c:line({ { 25, 30 }, { 21, 44 } }, 1):clip(hood), HOOD.hi)
local hem = {}
sh:each(function(x, y) if not sh:has(x, y + 1) and y > 70 and x % 3 == 0 then hem[#hem + 1] = { x, y - 1 } end end)
for _, q in ipairs(hem) do c:put(q[1], q[2], GOLDR.base) end
for y = 97, 99 do c:put(39, y, GOLDR.base) end
-- almond seed face
local fc = c:ellipse(39.5, 45, 13, 14)
fc:add(c:poly{ { 27, 50 }, { 52, 50 }, { 39.5, 68 } })
c:part(fc, BARK, { band = 2, pop = { x = 31, y = 36 } })
local ring = fc:copy():grow(1):cut(fc)
ring:each(function(x, y) if hood:has(x, y) and (x + y) % 3 == 0 then c:put(x, y, GOLDR.base) end end)
for y = 32, 37 do c:put(39, y, BARK.deep) end
c:put(40, 33, BARK.shade) c:put(38, 33, BARK.hi)
for _, q in ipairs{ { 29, 48 }, { 29, 49 }, { 29, 50 }, { 50, 46 }, { 50, 47 }, { 48, 58 }, { 47, 59 } } do c:put(q[1], q[2], BARK.shade) end
c:eyeLocked(32, 42) c:eyeLocked(43, 42)
-- twig-knot nose
for _, q in ipairs{ { 39, 49, BARK.hi }, { 40, 49, BARK.base }, { 38, 50, BARK.shade }, { 39, 50, BARK.base }, { 40, 50, BARK.shade }, { 41, 50, BARK.shade }, { 39, 51, BARK.shade }, { 40, 51, BARK.deep }, { 38, 49, BARK.deep } } do c:put(q[1], q[2], q[3]) end
for _, q in ipairs{ { 35, 55 }, { 36, 56 }, { 37, 57 }, { 38, 57 }, { 39, 57 }, { 40, 57 }, { 41, 57 }, { 42, 56 }, { 43, 55 } } do c:put(q[1], q[2], BARK.deep) end
c:put(39, 58, "#e0849a") c:put(40, 58, "#e0849a")
c:cheek(31, 52) c:cheek(46, 52)
c:part(c:ellipse(39.5, 71, 2.5, 2.5), GOLDR, { band = 1, pop = { x = 38, y = 70 } })
-- arm, cane and sprout
c:part(c:line({ { 61, 99 }, { 60, 80 }, { 61, 64 }, { 59, 57 } }, 3), BARK, { band = 1, nopop = true })
c:part(c:line({ { 50, 86 }, { 55, 79 }, { 57, 76 } }, 2), BARK, { band = 1, nopop = true })
c:part(c:ellipse(59.5, 76, 3, 2.5), BARK, { band = 1, pop = { x = 58, y = 75 } })
c:put(59, 77, BARK.deep) c:put(61, 77, BARK.deep)
c:part(c:ellipse(59.5, 55.5, 2.5, 2), BARK, { band = 1, pop = { x = 58, y = 54 } })
c:fillMask(c:line({ { 59, 53 }, { 59, 50 } }, 1), LEAF.shade)
c:part(c:ellipse(55, 49.5, 3.5, 1.5), LEAF, { band = 1, pop = { x = 53, y = 49 } })
c:part(c:ellipse(63.5, 48.5, 3.5, 1.5), LEAF, { band = 1, pop = { x = 62, y = 48 } })
c:put(55, 50, LEAF.deep) c:put(64, 49, LEAF.deep)
-- antennae
for _, s in ipairs{ -1, 1 } do
  local function X(x) return math.floor(39.5 + s * (39.5 - x)) end
  c:fillMask(c:line({ { X(33), 22 }, { X(30), 14 }, { X(26), 9 }, { X(21), 8 }, { X(19), 12 }, { X(22), 14 } }, 2), BARK.base)
end
c:put(29, 14, BARK.hi) c:put(25, 9, BARK.hi)
c:finish{ outline = true }
backdrop(c, DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
