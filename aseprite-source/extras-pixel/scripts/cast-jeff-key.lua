-- Jeff key (guest block "needs an account"): holding up a big gold key, bow on top, teeth to the right. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -6, 2
local body = K.jeffBody(c, dx, dy)
local armL = c:rrect(7, 37, 13, 43, 2); armL:add(c:ellipse(7.5, 40, 2, 3.5)); armL:cut(body:grow(1))
local armR = c:line({ {37, 38}, {43, 32}, {46, 29} }, 4); armR:cut(body:grow(1))
-- key: ring bow with a hole, 3 px shaft, two teeth
local key = c:ellipse(49, 12, 6, 6); key:cut(c:ellipse(49, 12, 2, 2))
key:add(c:rect(48, 17, 50, 41)); key:add(c:rect(51, 34, 54, 36)); key:add(c:rect(51, 38, 53, 40))
local fist = c:ellipse(48, 27, 3.5, 3.5)
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "key", key, "gold", { gloss = { 45, 8 } } },
  K.jeffArm("fist", fist),
}
c:paint({ "u.u" }, 47, 26, { u = "umber" })
K.jeffFace(c, dx, dy, "custom", { eyes = "open", brows = "raised", mouth = "smile" })
K.save(c, "jeff-key")
