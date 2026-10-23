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
local throat = GV.ramp("#d6dfe4", { shade = "#a9b6c8", deep = "#7d88a6", bounce = "#bcc6d4" })
local ice   = "glass"
local turf  = GV.ramp("#7f9a62", { shade = "#56724e", deep = "#344a3c", bounce = "#62804e" })
local dark  = GV.ramp("#3e2f66", { shade = "#291d4a", deep = "#1e1538", bounce = "#291d4a" })

-- barrow mound: a low dome of turf over a ring of kerb stones
local mound = c:ellipse(31.5, 60, 26, 19):clip(c:rect(0, 0, 63, 57))
local kerb = c:rrect(5, 52, 13, 57, 1):add(c:rrect(14, 53, 23, 57, 1)):add(c:rrect(24, 53, 33, 57, 1))
  :add(c:rrect(52, 52, 58, 57, 1))
-- stone doorway (posts + lintel) at the lower right, dark passage inside
local door  = c:rect(38, 48, 49, 57)
local posts = c:rect(35, 47, 38, 57):add(c:rect(49, 47, 52, 57))
local lintel = c:rrect(33, 44, 54, 47, 1)
local icicles = c:poly({ {37, 48}, {40, 48}, {38, 53} }):add(c:poly({ {41, 48}, {44, 48}, {42, 55} }))
  :add(c:poly({ {45, 48}, {48, 48}, {46, 52} })):add(c:poly({ {49, 48}, {52, 48}, {50, 51} }))

-- back ice shards, rising from the ridge (biggest in the middle)
local shards = c:poly({ {33, 27}, {36, 13}, {40, 27} })
  :add(c:poly({ {39, 28}, {44, 8}, {49, 29} }))
  :add(c:poly({ {47, 31}, {53, 16}, {55, 33} }))
  :add(c:poly({ {28, 26}, {30, 18}, {34, 26} }))

-- toad body (hunched, behind the head) and folded hind leg
local body = c:ellipse(37, 37, 17, 11)
local hind = c:ellipse(47, 42, 8, 6.5)
local hfoot = c:ellipse(52, 47.5, 5, 2)
-- big head facing left, eye bumps on top
local head = c:ellipse(21, 31, 14.5, 10)
local bumps = c:ellipse(15.5, 23, 5.5, 5):add(c:ellipse(28.5, 22, 5.5, 5))
local throatM = c:ellipse(20, 38, 10, 3.5)
-- near front leg and splayed toes on the mound
local fleg = c:rrect(17, 39, 23, 47, 2)
local ffoot = c:ellipse(18.5, 47.5, 6, 2)
local whole = body:copy():add(head):add(bumps):add(hind)

-- ice crown between the eye bumps
local crown = c:poly({ {17, 18}, {19, 11}, {22, 18} }):add(c:poly({ {20, 18}, {23, 8}, {26, 18} }))
  :add(c:poly({ {24, 18}, {27, 12}, {29, 18} }))

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
  { "crown",   crown, ice, { gloss = false } },
  { "head",    head, toad, { light = whole } },
  { "throat",  throatM, throat, { gloss = false } },
  { "fleg",    fleg, toad, { light = whole, gloss = false } },
  { "ffoot",   ffoot, toad, { light = whole, gloss = false } },
}

-- frost warts: slate beans on the back and head
c:spot(c:ellipse(30, 30, 1.5, 1), "#4e5f9a", "#8fb4d6")
c:spot(c:ellipse(43, 35, 1.5, 1), "#4e5f9a", "#8fb4d6")
c:spot(c:ellipse(36, 41, 1, 1.5), "#4e5f9a", "#8fb4d6")
c:spot(c:ellipse(47, 40, 1, 1.5), "#4e5f9a", "#8fb4d6")

-- stitched join: seam where the turf meets the kerb stones, button at its head
c:seam({ {7, 50}, {33, 50} })
c:button(3 + 3, 48)

-- face: wide locked eyes on the bumps, heavy frost brows, long downturned mouth
c:eye(13, 21); c:eye(26, 20)
c:paint({ "bbb...", "...bb." }, 11, 19, { b = "#2a1a10" })
c:paint({ ".bbb", "b..." }, 26, 18, { b = "#2a1a10" })
c:fill(c:line({ {8, 33}, {12, 34}, {20, 35}, {27, 35}, {31, 34} }, 1), "#2a1a10")
c:px(32, 35, "#2a1a10"); c:px(7, 32, "#2a1a10")
-- nostril
c:px(9, 29, "#3e4570"); c:px(10, 29, "#3e4570")
-- toe splits
c:paint({ "u.u" }, 16, 48, { u = "#4a2c1a" })
c:paint({ "u.u" }, 51, 48, { u = "#4a2c1a" })

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-nwe-4-lair-barrow-of-the-frost-toad.aseprite",
  PNG .. "creature-boss-lm-nwe-4-lair-barrow-of-the-frost-toad.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
