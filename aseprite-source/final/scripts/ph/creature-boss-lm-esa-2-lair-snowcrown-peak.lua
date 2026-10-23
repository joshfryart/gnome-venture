-- Guardian of Snowcrown Peak: legendary mountain lion (puma) boss, crouched on a peak rock,
-- snow on the shoulders, a little ice-and-snow crown, long dark-tipped tail raised.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tawny puma fur with a cool (mountain-shadow) shade
local fur   = GV.ramp("#c98f52", { shade = "#9a6c5c", deep = "#5e4050", bounce = "#ab7a5e" })
local cream = GV.ramp("#f1e2c4")
local tip   = GV.ramp("#5e2f1e")
local snow  = GV.ramp("#eef2ec", { dot = "#f8fcf4", shade = "#bccce0", deep = "#8a9cc0", bounce = "#cad6e4" })
local ice   = "glass"

-- peak rock: a slab with a raised left shoulder
local rock = c:poly({ {6, 57}, {6, 42}, {8, 37}, {12, 36}, {15, 41}, {22, 45}, {34, 45}, {44, 46}, {51, 45}, {56, 50}, {56, 57} })
local rockSnow = c:ellipse(10, 37.5, 4, 2):add(c:rect(7, 38, 8, 40)):add(c:rect(12, 38, 13, 39))

-- long tail curling up on the right, dark tip
local tail = c:line({ {46, 43}, {51, 40}, {54, 34}, {54, 28}, {52, 24} }, 4)
local tailTip = c:ellipse(51.5, 22.5, 3, 3)

local hind = c:ellipse(45, 41, 7, 6.5)
local body = c:ellipse(35, 38, 15, 8.5)
local paws = c:ellipse(15.5, 46.5, 5, 2.5):add(c:ellipse(30.5, 47, 5, 2.5))
local whole = body:copy():add(hind):add(tail):add(paws):add(c:ellipse(26, 25, 13, 11))

-- small round puma ears (no tufts)
local ears = c:poly({ {10, 20}, {11, 11}, {14, 9}, {20, 15} }):add(c:poly({ {32, 15}, {38, 9}, {41, 11}, {42, 20} }))
local innerEars = c:poly({ {12, 17}, {13, 12}, {17, 15} }):add(c:poly({ {35, 15}, {39, 12}, {40, 17} }))
local head = c:ellipse(26, 24.5, 13, 10.5):add(c:ellipse(26, 29, 10, 6))
local muzzle = c:ellipse(26, 31, 6.5, 3.5)

-- snow heaped on the shoulders and back
local shoulderSnow = c:ellipse(43, 30.5, 5, 2.5):add(c:ellipse(50, 33.5, 4, 2.5)):add(c:rect(40, 31, 41, 33)):add(c:rect(46, 32, 47, 34))

-- little snow crown: snow band with ice points
local band = c:rrect(18, 12, 34, 15, 1)
local points = c:poly({ {18, 13}, {19, 8}, {23, 13} })
  :add(c:poly({ {22, 13}, {26, 6}, {31, 13} }))
  :add(c:poly({ {29, 13}, {33, 8}, {35, 13} }))

c:build{
  { "rock",   rock, "stone" },
  { "rsnow",  rockSnow, snow, { gloss = false } },
  { "tail",   tail, fur, { light = whole } },
  { "tip",    tailTip, tip },
  { "hind",   hind, fur, { light = whole } },
  { "body",   body, fur, { light = whole } },
  { "ssnow",  shoulderSnow, snow },
  { "paws",   paws, fur, { light = whole } },
  { "ears",   ears, fur, { light = head:copy():add(ears) } },
  { "inner",  innerEars, tip, { flat = true, contour = false } },
  { "head",   head, fur },
  { "muzzle", muzzle, cream, { flat = true } },
  { "points", points, ice },
  { "band",   band, snow, { gloss = false } },
}

-- stitched join: crown band seam, toe seams on the paws
c:seam({ {19, 14}, {33, 14} })
c:paint({ "u.u" }, 14, 47, { u = "#4a2c1a" })
c:paint({ "u.u" }, 28, 47, { u = "#4a2c1a" })

-- plain puma face: wide locked eyes, dark nose, a battle scar over the right eye
c:eye(17, 22); c:eye(30, 22)
c:paint({ "nnnn", ".nn." }, 24, 29, { n = "#2a1a10" })
c:paint({ "..mm..", ".m..m." }, 23, 31, { m = "#4a2c1a" })
-- stern brows and a scar over the right eye
c:paint({ "bb...", "..bb." }, 16, 20, { b = "#4a2c1a" }); c:paint({ ".bb", "b.." }, 32, 20, { b = "#4a2c1a" })
c:paint({ "...s", "..s.", ".s..", "s..." }, 34, 18, { s = "#5e4050" })

local t = c:save(D .. "final/aseprite/ph/creature-boss-lm-esa-2-lair-snowcrown-peak.aseprite",
  PNG .. "creature-boss-lm-esa-2-lair-snowcrown-peak.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
