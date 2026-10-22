local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- grey-brown from stone family (#8b8f96 warmed)
local grey  = GV.ramp("#a38f80")
local dgrey = GV.ramp("#8f7060")
local band  = GV.ramp("#4e3e3c")
local cream = GV.ramp("#f8eed2")

local ears = c:ellipse(20, 16, 5, 4.5):add(c:ellipse(43, 16, 5, 4.5))
local feet = c:ellipse(22, 53, 6.5, 3.5):add(c:ellipse(41, 53, 6.5, 3.5))
local body = c:ellipse(31.5, 42, 17, 13)
local head = c:ellipse(31.5, 26, 14, 12.5)

local p = c:build{
  { "tail",  c:ellipse(49, 49, 3.5, 3.5), dgrey },
  { "ears",  ears, grey },
  { "body",  body, grey, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(31.5, 46, 9.5, 8), dgrey, { gloss = false } },
  { "feet",  feet, dgrey },
  { "head",  head, grey },
  -- dark eye bands (the darker cheeks) either side of the stripe
  { "bandL", c:poly({ {19, 17}, {27, 15}, {28, 30}, {21, 31}, {18, 25} }), band, { gloss = false, rim = false } },
  { "bandR", c:poly({ {36, 15}, {44, 17}, {46, 25}, {43, 31}, {35, 30} }), band, { gloss = false } },
  -- cream wedge brow to nose
  { "stripe", c:poly({ {28, 13}, {36, 13}, {35, 30}, {29, 30} }), cream },
  { "muzzle", c:ellipse(31.5, 32.5, 5, 4), cream, { gloss = false } },
}
-- inner ears
c:fill(c:ellipse(20, 16, 2, 2), band.base)
c:fill(c:ellipse(43, 16, 2, 2), band.base)
-- nose
c:paint({ ".nnnn.", "nnnnnn", ".nnnn." }, 29, 31, { n = "#2a1a10" })
c:px(30, 31, "#5e2a3a")
-- mouth
c:paint({ "m....m", ".mmmm." }, 29, 34, { m = "#4a2c1a" })
-- eyes inside the dark bands
c:eye(21, 21); c:eye(38, 21)
c:seam({ {31, 39}, {31, 53} })
c:ground(31.5, 56, 17, 1)
local t = c:save(O .. "aseprite/ph/creature-badger.aseprite", O .. "png/ph/creature-badger.png")
print(GV.report(t))
