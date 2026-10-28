-- Jeff oops (retry / error): scratching the back of his head, grimace, sweat drop, a dropped piece falling. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 1, 1
local body = K.jeffBody(c, dx, dy)
-- right arm bent up, hand behind the head; left arm tab reaching down after the piece
local armR = c:line({ {45, 36}, {51, 28}, {48, 20} }, 4); armR:add(c:ellipse(46, 17, 3.5, 3.5)); armR:cut(body:grow(1))
local armL = c:line({ {18, 37}, {12, 39} }, 4); armL:add(c:ellipse(10, 39, 3, 3)); armL:cut(body:grow(1))
local drop = c:ascii({ "..d..", "..d..", ".ddd.", ".ddd.", "ddddd", "ddddd", ".ddd." }, 8, 17)
-- dropped piece: a bigger copy of Jeff's purple mini, tumbling past the left foot
local mini = c:rrect(6, 47, 14, 55, 1); mini:add(c:ellipse(10, 45.5, 2.5, 2.5)); mini:add(c:ellipse(15.5, 51, 2, 2.5))
mini:cut(c:ellipse(10, 56, 2, 1.5))
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "drop", drop, "water", { flat = true, contact = false } },
  { "mini", mini, GV.ramp("#8a5fd0"), { contact = false, gloss = { 8, 49 } } },
}
c:paint({ "g", "g" }, 5, 38, { g = "#f5cf6a" }); c:paint({ "g", "g" }, 15, 42, { g = "#f5cf6a" })  -- fall ticks
c:px(9, 20, "#eaf8e4")
K.jeffFace(c, dx, dy, "custom", { eyes = "wince", brows = "worried", mouth = "grimace" })
K.save(c, "jeff-oops")
