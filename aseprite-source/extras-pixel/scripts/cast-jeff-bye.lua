-- Jeff bye (last tour stop, logout, purge): waving goodbye with happy shut eyes, little suitcase in the other hand. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 0, 1
local body = K.jeffBody(c, dx, dy)
local armL = c:line({ {18, 35}, {12, 29}, {10, 20} }, 4); armL:add(c:ellipse(9, 16, 3.5, 3.5)); armL:cut(body:grow(1))
local armR = c:line({ {45, 38}, {48, 39} }, 4); armR:cut(body:grow(1))
local case = c:rrect(41, 43, 56, 55, 2)
local hdl = c:rect(46, 39, 51, 40):add(c:rect(46, 41, 46, 42)):add(c:rect(51, 41, 51, 42))
local fist = c:ellipse(48.5, 39, 2.5, 2.5)
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "hdl", hdl, "wood", { flat = true } },
  { "case", case, "wood", { gloss = { 43, 45 } } },
  K.jeffArm("fist", fist),
}
c:paint({ "ss", "ss" }, 44, 47, { s = "#f5cf6a" }); c:paint({ "ss", "ss" }, 52, 47, { s = "#f5cf6a" }); c:paint({ "uuuuuuuuuu" }, 44, 51, { u = GV.R.wood.shade })   -- brass latches
c:paint({ "u.u" }, 7, 13, { u = "umber" })
c:paint({ "g", "g", ".", "g" }, 4, 9, { g = "#f5cf6a" }); c:paint({ "gg" }, 12, 8, { g = "#f5cf6a" })
K.jeffFace(c, dx, dy, "custom", { eyes = "happy", mouth = "smile" })
K.save(c, "jeff-bye")
