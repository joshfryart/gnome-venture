local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local fur   = GV.ramp("#a38f80")
local dark  = GV.ramp("#8f7060")
local horn  = GV.ramp("#b6814d")
local cream = GV.ramp("#f8eed2")
local nose  = GV.ramp("#3a2a26")

-- antlers: main beam + outward tine, mirrored
local antL = c:line({ {27, 21}, {24, 16}, {22, 12} }, 3)
antL:add(c:line({ {24, 17}, {19, 15}, {17, 13} }, 2))
local antR = c:line({ {36, 21}, {39, 16}, {41, 12} }, 3)
antR:add(c:line({ {39, 17}, {44, 15}, {46, 13} }, 2))

local lichen = c:ellipse(21.5, 11.5, 2.5, 2)
lichen:add(c:ellipse(41.5, 11.5, 2.5, 2))
lichen:add(c:ellipse(16.5, 13, 1.5, 1.5))
lichen:add(c:ellipse(46.5, 13, 1.5, 1.5))

local ears = c:ellipse(19, 25, 4.5, 2.5):add(c:ellipse(45, 25, 4.5, 2.5))
local inner = c:ellipse(18.5, 25, 2.5, 1):add(c:ellipse(45.5, 25, 2.5, 1))

local feet = c:ellipse(24, 50, 4.5, 2.5):add(c:ellipse(40, 50, 4.5, 2.5))

local p = c:build{
  { "tail",   c:ellipse(46, 38, 3, 3),        dark },
  { "antL",   antL,                           horn, { flat = true } },
  { "antR",   antR,                           horn, { flat = true } },
  { "lichen", lichen,                         "moss", { gloss = false } },
  { "ears",   ears,                           fur },
  { "inner",  inner,                          cream, { flat = true } },
  { "feet",   feet,                           dark },
  { "body",   c:ellipse(32, 42, 14, 9),       fur, { stitch = { side = "lit" } } },
  { "belly",  c:ellipse(32, 45, 7.5, 5.5),    cream },
  { "head",   c:ellipse(32, 29, 10, 10),      fur },
  { "muzzle", c:ellipse(32, 34, 3.5, 6),      cream },
  { "nose",   c:ellipse(32, 38, 2, 1.5),      nose, { flat = true } },
}

c:eye(24, 25); c:eye(35, 25)

local t = c:save(O .. "aseprite/ph/creature-lichen-reindeer.aseprite", O .. "png/ph/creature-lichen-reindeer.png")
print(GV.report(t))
