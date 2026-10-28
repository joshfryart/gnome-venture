-- Jeff water (Rain Barrel host): tipping a blue watering can, drops falling from the rose. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -6, 2
local body = K.jeffBody(c, dx, dy)
local armL = c:rrect(7, 37, 13, 43, 2); armL:add(c:ellipse(7.5, 40, 2, 3.5)); armL:cut(body:grow(1))
-- can: body, spout up-right to a rose, top handle loop; hand on the handle
local can = c:rrect(35, 30, 47, 43, 3)
local spout = c:line({ {46, 37}, {52, 30} }, 3); spout:add(c:rrect(51, 26, 55, 30, 1))
local hdl = c:line({ {37, 32}, {39, 26}, {44, 26}, {46, 32} }, 2)
local armR = c:line({ {36, 36}, {39, 30} }, 4); armR:cut(body:grow(1))
local fist = c:ellipse(39, 27, 3, 3)
local d1 = c:ascii({ ".d.", "ddd", "ddd" }, 53, 34)
local d2 = c:ascii({ ".d.", "ddd", "ddd" }, 49, 40)
local d3 = c:ascii({ ".d.", "ddd", "ddd" }, 53, 46)
c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body),
  { "hdl", hdl, "water", { flat = true } },
  { "spout", spout, "water", { flat = true } },
  { "can", can, "water", { gloss = { 38, 33 } } },
  K.jeffArm("armR", armR), K.jeffArm("fist", fist),
  { "d1", d1, "glass", { flat = true, contact = false } },
  { "d2", d2, "glass", { flat = true, contact = false } },
  { "d3", d3, "glass", { flat = true, contact = false } },
}
c:paint({ "ss.ss" }, 37, 39, { s = GV.R.water.shade })               -- band on the can
K.jeffFace(c, dx, dy, "custom", { eyes = "right", mouth = "smile" })
K.save(c, "jeff-water")
