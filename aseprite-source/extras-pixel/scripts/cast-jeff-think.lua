-- Jeff think (tips): hand on chin, one brow up, a small flat mouth, a lit bulb over his head. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = -3, 3
local body = K.jeffBody(c, dx, dy)

-- left arm tab; right arm bent up so the hand rests under the chin
local armL = c:rrect(10, 37, 15, 43, 2); armL:add(c:ellipse(10, 40, 3, 4))
armL:cut(body:grow(1))
local armR = c:line({ {42, 40}, {47, 44}, {43, 48} }, 4)
armR:cut(body:grow(1))
armR:add(c:ellipse(37, 47, 3.5, 3))                                  -- fist tucked under the chin, on the body

-- light bulb, top right: gold glass, stone screw base
local bulb = c:ellipse(49.5, 12, 5.5, 5.5); bulb:add(c:poly({ {46, 14}, {54, 14}, {53, 19}, {47, 19} }))
local base = c:rrect(47, 19, 52, 23, 1)

c:build{
  K.jeffArm("armL", armL), K.jeffBodyPart(body), K.jeffArm("armR", armR),
  { "base", base, "stone", { flat = true } },
  { "bulb", bulb, GV.ramp("#f5cf6a"), { gloss = { 46, 9 } } },
}
-- bulb filament and screw lines
c:paint({ "u.u", ".u." }, 48, 14, { u = "#b8661a" })
c:paint({ "ssssss" }, 47, 21, { s = "#5b6470" })
-- rays off the bulb (flat gold, 2 px)
c:paint({ "gg" }, 40, 5, { g = "#f5cf6a" }); c:paint({ "gg" }, 56, 5, { g = "#f5cf6a" })
c:paint({ "g", "g" }, 49, 4, { g = "#f5cf6a" })
c:paint({ "gg" }, 40, 12, { g = "#f5cf6a" }); c:paint({ "gg" }, 57, 12, { g = "#f5cf6a" })

K.jeffFace(c, dx, dy, "hmm")                                         -- one brow up, small tilted mouth
K.save(c, "jeff-think")
