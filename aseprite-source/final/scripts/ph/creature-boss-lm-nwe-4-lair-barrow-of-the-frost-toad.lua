-- Frost Toad: legendary keeper of the Barrow of the Frost Toad (tundra lair boss).
-- A great pale blue-grey toad in 3/4 view facing left, ice shards jutting from its back
-- and an ice crown on its head, squatting on an old grass-and-stone barrow mound
-- with a dark stone doorway hung with icicles.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- palettes: toad borrows the stone family shifted cold blue-grey; ice = glass preset;
-- barrow turf = moss family dulled for tundra
local toad  = GV.ramp("#7d90a6", { shade = "#5d6890", deep = "#3e4570", bounce = "#6a7898" })
local throat = GV.ramp("#b4c2cc", { shade = "#8e9cb4", deep = "#6a7598", bounce = "#9eabc0" })
local ice   = "glass"
local turf  = GV.ramp("#7f9a62", { shade = "#56724e", deep = "#344a3c", bounce = "#62804e" })
local dark  = GV.ramp("#3e2f66", { shade = "#291d4a", deep = "#1e1538", bounce = "#291d4a" })

-- barrow mound: a low dome of turf over a ring of kerb stones
local mound = c:ellipse(31, 59, 25, 20):clip(c:rect(0, 0, 63, 56))
local kerb = c:rrect(7, 51, 15, 56, 1):add(c:rrect(16, 52, 25, 56, 1))
  :add(c:rrect(39, 52, 47, 56, 1)):add(c:rrect(48, 51, 55, 56, 1))
-- stone doorway (posts + lintel) in the front of the mound, dark passage inside
local door  = c:rect(29, 48, 35, 56)
local posts = c:rect(26, 47, 28, 56):add(c:rect(36, 47, 38, 56))
local lintel = c:rrect(24, 44, 40, 47, 1)
local icicles = c:poly({ {29, 48}, {31, 48}, {30, 53} }):add(c:poly({ {31, 48}, {34, 48}, {32, 55} }))
  :add(c:poly({ {34, 48}, {36, 48}, {35, 52} }))

-- back ice shards, rising from the ridge (biggest in the middle)
local shards = c:poly({ {32, 26}, {35, 13}, {39, 26} })
  :add(c:poly({ {38, 27}, {43, 7}, {48, 28} }))
  :add(c:poly({ {46, 30}, {52, 15}, {55, 33} }))

-- toad body (hunched, behind the head) and folded hind leg
local body = c:ellipse(38, 34, 14, 10)
local hind = c:ellipse(47, 39, 6.5, 5.5)
local hfoot = c:ellipse(50, 45, 5, 2)
-- big flat head facing left, eye bumps standing up on top
local head = c:ellipse(22, 30, 14, 8.5)
local jaw = head:copy():clip(c:rect(0, 33, 63, 63))
head:cut(jaw)
local bumps = c:ellipse(15.5, 20, 5.5, 5.5):add(c:ellipse(28.5, 19, 5.5, 5.5))
-- near front leg and splayed toes on the mound
local fleg = c:rrect(13, 37, 19, 44, 2)
local ffoot = c:ellipse(15, 45, 5, 2)
local whole = body:copy():add(head):add(jaw):add(bumps):add(hind)

-- ice crown between the eye bumps
local crown = c:poly({ {19, 15}, {22, 5}, {26, 15} })
  :add(c:poly({ {16, 15}, {16, 8}, {21, 15} })):add(c:poly({ {24, 15}, {29, 8}, {29, 15} }))
local crownBand = c:rrect(16, 14, 28, 16, 1)

c:build{
  { "mound",   mound, turf },
  { "kerb",    kerb, "stone", { gloss = false } },
  { "door",    door, dark, { gloss = false, rim = false } },
  { "posts",   posts, "stone", { gloss = false } },
  { "icicles", icicles, ice, { flat = true, contour = false } },
  { "lintel",  lintel, "stone" },
  { "shards",  shards, ice },
  { "hind",    hind, toad, { light = whole } },
  { "body",    body, toad, { light = whole, gloss = false } },
  { "hfoot",   hfoot, toad, { light = whole, gloss = false } },
  { "bumps",   bumps, toad, { light = whole, gloss = false } },
  { "head",    head, toad, { light = whole } },
  { "jaw",     jaw, throat, { light = whole, gloss = false } },
  { "fleg",    fleg, toad, { gloss = false } },
  { "ffoot",   ffoot, toad, { gloss = false } },
  { "crown",   crown, ice, { gloss = false, cres = 2, deep = 3 } },
  { "band",    crownBand, "#5a86b8", { gloss = false } },
}

-- frost warts: slate beans on the back and head
c:spot(c:ellipse(31, 29, 1.5, 1), "#4e5f9a", "#8fb4d6")
c:spot(c:ellipse(43, 33, 1.5, 1), "#4e5f9a", "#8fb4d6")
c:spot(c:ellipse(37, 39, 1, 1.5), "#4e5f9a", "#8fb4d6")
c:spot(c:ellipse(47, 38, 1, 1.5), "#4e5f9a", "#8fb4d6")

-- stitched join: seam where the turf meets the kerb stones, button at its head
c:seam({ {11, 50}, {23, 50} })
c:seam({ {41, 50}, {52, 50} })
c:button(7, 48)
c:seam({ {18, 15}, {27, 15} })

-- face: wide locked eyes on the bumps, heavy frost brows, long downturned mouth
c:eye(13, 18); c:eye(26, 17)
c:paint({ "bb....", "..bbbb" }, 11, 15, { b = "#2a1a10" })
c:paint({ "...bb", "bbb.." }, 25, 14, { b = "#2a1a10" })
-- nostril
c:px(10, 28, "#3e4570"); c:px(11, 28, "#3e4570")
-- toe splits
c:paint({ "u.u" }, 13, 45, { u = "#4a2c1a" })
c:paint({ "u.u" }, 49, 45, { u = "#4a2c1a" })

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-nwe-4-lair-barrow-of-the-frost-toad.aseprite",
  PNG .. "creature-boss-lm-nwe-4-lair-barrow-of-the-frost-toad.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
