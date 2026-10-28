-- Jeff piece (Jigsaw library host): holds one jigsaw piece up high in his left hand, grinning.
-- The piece shows a scrap of the picture (sky, sun, green hill). Right arm rests. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 5, 4
local body = K.jeffBody(c, dx, dy)
-- left arm raised up-left to the piece; right arm a short tab at the side
local armL = c:line({ {23, 38}, {17, 33}, {15, 28} }, 4); armL:cut(body:grow(1))
local armR = c:rrect(47, 38, 52, 44, 2); armR:add(c:ellipse(53, 41, 2, 3)); armR:cut(body:grow(1))
-- the piece: 13x12 block, knob top and right, notch left, bottom gripped by the fist
local piece = c:rrect(7, 11, 19, 22, 2)
piece:add(c:ellipse(13, 9, 3, 2.5)); piece:add(c:ellipse(21.5, 16.5, 2.5, 2.5))
piece:cut(c:ellipse(6, 16.5, 2, 2.5))
local hill = c:ellipse(10, 26, 13, 8):clip(piece)
local sun = c:ellipse(16, 14, 2, 2):clip(piece)
local fist = c:ellipse(14.5, 25, 3.5, 3)
c:build{
  K.jeffArm("armR", armR), K.jeffBodyPart(body), K.jeffArm("armL", armL),
  { "piece", piece, GV.ramp("#7fc0de"), { gloss = { 9, 12 }, stitch = { side = "lit" } } },
  { "sun", sun, "gold", { flat = true, contour = false, contact = false } },
  { "hill", hill, GV.ramp("#94c46e"), { flat = true, contact = false } },
  K.jeffArm("fist", fist),
}
c:paint({ "u.u" }, 13, 23, { u = "umber" })                                 -- fingers over the piece
c:paint({ "g.", ".g" }, 6, 6, { g = "#f5cf6a" })                            -- shine ticks
c:paint({ "gg" }, 19, 6, { g = "#f5cf6a" }); c:paint({ "g", "g" }, 3+1, 22, { g = "#f5cf6a" })
K.jeffFace(c, dx, dy, "grin")
K.save(c, "jeff-piece")
