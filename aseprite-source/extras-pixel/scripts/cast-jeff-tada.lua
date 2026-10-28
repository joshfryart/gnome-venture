-- Jeff tada (new game, arrival, hero): left hand flung out, right hand firing a party popper, happy shut eyes. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -3, 3
local body = K.jeffBody(c, dx, dy)
local armL = c:line({ {15, 37}, {9, 31}, {8, 25} }, 4); armL:add(c:ellipse(9.5, 22, 3.5, 3.5)); armL:cut(body:grow(1))
local armR = c:line({ {41, 41}, {45, 40} }, 4); armR:cut(body:grow(1))
-- popper: red cone, mouth up-right, held at the tip
local cone = c:poly({ {44, 43}, {46, 27}, {56, 34} })
local fist = c:ellipse(46, 41, 3, 3)
-- streamers and bits bursting out of the cone
local function dia(x, y) return c:ascii({ ".x.", "xxx", ".x." }, x, y) end
local s1 = c:line({ {48, 26}, {46, 20}, {49, 14} }, 3)
local s2 = c:line({ {53, 29}, {54, 23} }, 3)
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "cone", cone, "red", { gloss = false } },
  K.jeffArm("fist", fist),
  { "s1", s1, GV.ramp("#f5cf6a"), { flat = true, contact = false } },
  { "s2", s2, GV.ramp("#8a5fd0"), { flat = true, contact = false } },
  { "b1", dia(41, 8), GV.ramp("#3f8fb0"), { flat = true, contact = false } },
  { "b2", dia(53, 13), GV.ramp("#dd3a2a"), { flat = true, contact = false } },
  }
c:paint({ "ggg", ".ggg" }, 46, 35, { g = "#f5cf6a" })                         -- band on the cone
c:paint({ "g", "g", ".", "g" }, 5, 15, { g = "#f5cf6a" }); c:paint({ "gg" }, 12, 13, { g = "#f5cf6a" })  -- jazz-hand ticks
K.jeffFace(c, dx, dy, "custom", { eyes = "happy", mouth = "open" })
K.save(c, "jeff-tada")
