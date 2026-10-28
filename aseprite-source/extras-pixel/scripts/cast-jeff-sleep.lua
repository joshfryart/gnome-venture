-- Jeff sleep (daily done, caps, guest expired): eyes shut, small open mouth, purple nightcap, Zzz rising. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -4, 3
local body = K.jeffBody(c, dx, dy)
local armL = c:rrect(9, 40, 15, 46, 2); armL:add(c:ellipse(9.5, 43, 2, 3)); armL:cut(body:grow(1))
local armR = c:rrect(38, 40, 46, 46, 2); armR:add(c:ellipse(46, 43, 2, 3)); armR:cut(body:grow(1))
-- nightcap over the knob, tip flopping left to a gold pompom; cream brim band
local cap = c:poly({ {18, 18}, {36, 17}, {32, 8}, {26, 7} })
cap:add(c:line({ {26, 8}, {18, 7}, {13, 11} }, 4))
local brim = c:rrect(17, 16, 37, 19, 1)
local pom = c:ellipse(11, 13, 3, 3)
-- Zz: two chunky Zs rising to the right (2 px strokes)
local function Z(x, y, big)
  if big then return c:ascii({ "zzzzzzzz", "zzzzzzzz", ".....zzz", "....zzz.", "...zzz..", "..zzz...", ".zzz....", "zzzzzzzz", "zzzzzzzz" }, x, y) end
  return c:ascii({ "zzzzzz", "zzzzzz", "...zz.", "..zz..", ".zz...", "zzzzzz", "zzzzzz" }, x, y)
end
c:build{
  K.jeffArm("armL", armL), K.jeffArm("armR", armR), K.jeffBodyPart(body),
  { "cap", cap, GV.ramp("#8a5fd0"), {} },
  { "brim", brim, "cream", { flat = true } },
  { "pom", pom, GV.ramp("#f5cf6a"), {} },
  { "z1", Z(46, 22, true), GV.ramp("#3f8fb0"), { flat = true, contact = false } },
  { "z2", Z(51, 7), GV.ramp("#3f8fb0"), { flat = true, contact = false } },
}
K.jeffFace(c, dx, dy, "custom", { eyes = "shut", mouth = "o", nobutton = true })
K.save(c, "jeff-sleep")
