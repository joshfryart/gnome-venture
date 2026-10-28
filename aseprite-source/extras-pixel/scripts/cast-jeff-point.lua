-- Jeff point (tour stops, guest page, hub): right arm straight out, index finger pointing right, eyes following it. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -5, 2
local body = K.jeffBody(c, dx, dy)
-- left arm: short tab; right arm: straight out, fist with a 2 px index finger
local armL = c:rrect(7, 37, 14, 43, 2); armL:add(c:ellipse(8, 40, 2.5, 3.5)); armL:cut(body:grow(1))
local armR = c:line({ {38, 38}, {49, 36} }, 4); armR:cut(body:grow(1))
armR:add(c:ellipse(50, 37, 3, 3)); armR:add(c:rect(52, 35, 56, 36))
c:build{ K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR) }
c:paint({ "u", "u" }, 51, 37, { u = "umber" })                       -- curled fingers under the pointer
K.jeffFace(c, dx, dy, "custom", { eyes = "right", brows = "raised", mouth = "smile" })
K.save(c, "jeff-point")
