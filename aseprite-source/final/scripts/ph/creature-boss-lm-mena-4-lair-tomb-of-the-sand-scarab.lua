-- Sand Scarab (boss, desert, lv 30): a cart-sized scarab seen side-on, facing left, lapis wing case
-- with a gold sun-disc sewn on it, sandy-gold pronotum, dark head with a toothed gold clypeus crown,
-- and the sandstone door of its tomb rising behind it.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local FILE = "creature-boss-lm-mena-4-lair-tomb-of-the-sand-scarab"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local LAPIS = GV.ramp("#2f6290")              -- water family, deep lapis
local SAND  = GV.ramp("#c9a96e")              -- soil family, sandstone
local DOOR  = GV.ramp("#3d2a1c")              -- soil family, dark doorway
local GOLD  = GV.R.gold

-- tomb door (back): sandstone pylon with a lintel, dark doorway
local tomb = c:poly({ {35,10}, {54,10}, {56,32}, {33,32} })
local lintel = c:rrect(32, 6, 57, 10, 1)
local door = c:rect(41, 14, 48, 32)

-- legs (behind the body), 3 px, bent, feet planted
local legs = c:line({ {20,44}, {15,49}, {13,54} }, 3)
legs:add(c:line({ {31,45}, {29,50}, {26,54} }, 3))
legs:add(c:line({ {43,45}, {47,49}, {48,54} }, 3))
legs:add(c:line({ {50,43}, {54,47}, {55,53} }, 3))

-- wing case: big dome, flat underside
local shell = c:ellipse(39.5, 37, 16.5, 13):cut(c:rect(0, 45, 63, 63))
shell:add(c:rrect(25, 39, 54, 46, 5))
-- pronotum (sandy gold shield between head and wings)
local prono = c:ellipse(24.5, 37, 7.5, 9.5)
-- head with a toothed clypeus crown
local head = c:ellipse(15.5, 40, 9.5, 8.5)
local crown = c:poly({ {8,35}, {6,25}, {11,30}, {15.5,20}, {20,30}, {25,25}, {23,35} })

local p = c:build{
  { "tomb",   tomb,   SAND, { gloss = false } },
  { "lintel", lintel, SAND, { gloss = { 33, 7 } } },
  { "door",   door,   DOOR, { gloss = false, rim = false } },
  { "legs",   legs,   "leg", { flat = true } },
  { "shell",  shell,  LAPIS, { gloss = { 30, 28 } } },
  { "prono",  prono,  GOLD, { gloss = { 20, 31 } } },
  { "head",   head,   "dusk", { gloss = { 9, 35 } } },
  { "crown",  crown,  GOLD, { gloss = { 14, 26 } } },
}

-- glyph on the lintel: eye of the sun
c:paint({ ".ggg.", "g.u.g", ".ggg." }, 42, 7, { g = "#7a3a14", u = "#2a1a10" })
-- stone block lines on the pylon
c:fill(c:rect(35, 19, 39, 19), SAND.shade); c:fill(c:rect(50, 19, 54, 19), SAND.shade)
c:fill(c:rect(37, 13, 37, 18), SAND.shade); c:fill(c:rect(52, 13, 52, 18), SAND.shade)

-- sun-disc sewn on the wing case: gold disc, rays, stitched ring
c:spot(c:ellipse(41, 34, 4, 4), GOLD.base, GOLD.gloss)
c:fill(c:ellipse(42, 35, 2, 2), GOLD.shade)
c:px(41, 34, GOLD.gloss)
local rays = { {41,27}, {41,28}, {41,40}, {41,41}, {34,34}, {35,34}, {47,34}, {48,34},
               {36,29}, {37,30}, {46,29}, {45,30}, {36,39}, {37,38}, {46,39}, {45,38} }
for _, r in ipairs(rays) do c:px(r[1], r[2], GOLD.rim) end
-- hem seam where the wing case meets the belly, button at its head
c:seam({ {30, 44}, {54, 44} })
c:button(27, 42)
-- seam where the pronotum joins the wing case
c:seam({ {31, 30}, {31, 42} })

-- crown jewel (lapis bead) under the centre notch
c:fill(c:rect(15, 31, 16, 32), LAPIS.base)

-- angry face, eyes wide
c:eye(8, 39); c:eye(17, 39)

-- stitched scar across the wing case
c:fill(c:line({ {49,32}, {53,37} }, 1), LAPIS.deep)
c:px(50, 35, GV.C.gold); c:px(52, 33, GV.C.gold)

c:ground(33, 55, 23, 1.5)
local t = c:save(D .. "final/aseprite/ph/" .. FILE .. ".aseprite", PNG .. FILE .. ".png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
