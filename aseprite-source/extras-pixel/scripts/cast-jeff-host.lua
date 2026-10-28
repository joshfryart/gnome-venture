-- Jeff host (Puzzles library header): Jeff v2 body and face, left arm raised in a wave, right arm resting. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = K.jeffBody(c, 0, 0)

-- left arm: raised high, waving (bent at the elbow), open hand
local armL = c:line({ {18, 34}, {12, 28}, {10, 19} }, 4)
armL:add(c:ellipse(9, 15, 3.5, 3.5))                                  -- hand
armL:cut(body:grow(1))
-- right arm: short tab at the side
local armR = c:rrect(44, 36, 52, 42, 2); armR:add(c:ellipse(53, 39, 3, 4))
armR:cut(body:grow(1))

c:build{ K.jeffArm("armL", armL), K.jeffArm("armR", armR), K.jeffBodyPart(body) }
-- fingers on the waving hand
c:paint({ "u.u" }, 7, 12, { u = "umber" })                         -- finger splits
c:paint({ "g", "g", ".", "g" }, 4, 8, { g = "#f5cf6a" }); c:paint({ "gg" }, 12, 7, { g = "#f5cf6a" })  -- wave ticks
K.jeffFace(c, 0, 0, "grin")                                          -- wide eyes, raised brow, toothy grin
K.save(c, "jeff-host")
