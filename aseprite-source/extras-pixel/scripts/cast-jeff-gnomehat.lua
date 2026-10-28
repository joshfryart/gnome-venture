-- Jeff gnome hat (Gnome Beds host, customise): tall red gnome hat over his knob, tip flopping, hand at the brim. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 0, 4
local body = K.jeffBody(c, dx, dy)
local armL = c:line({ {18, 38}, {12, 32}, {13, 26} }, 4); armL:add(c:ellipse(15, 24, 3, 3)); armL:cut(body:grow(1))
local armR = c:rrect(44, 40, 52, 46, 2); armR:add(c:ellipse(53, 43, 3, 4)); armR:cut(body:grow(1))
-- hat: cone from a wide brim up to a tip that flops over to the right
local hat = c:poly({ {19, 25}, {43, 24}, {36, 12}, {30, 8}, {25, 13} })
hat:add(c:line({ {30, 10}, {38, 8}, {45, 11}, {48, 16} }, 4))
c:build{
  K.jeffArm("armR", armR), K.jeffBodyPart(body),
  { "hat", hat, "red", { gloss = { 26, 15 } } },
  K.jeffArm("armL", armL),
}
c:seam({ {21, 23}, {41, 22} })                                        -- stitched hat band
K.jeffFace(c, dx, dy, "custom", { eyes = "open", brows = "raised", mouth = "grin", nobutton = true })
K.save(c, "jeff-gnomehat")
