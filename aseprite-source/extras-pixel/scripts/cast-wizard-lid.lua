-- Wizard lid (Jigsaw Guide help): the Old Wizard holds the puzzle-box lid up beside him so you can see
-- the picture (tiny sky, sun, hills, red-cap cottage); his other hand points at it. 64x64 sticker.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 4, 4
local body, _, hat, beard = K.wizardShapes(c, dx, dy)
-- own arms: left raised to the lid's lower corner, right bent across the chest pointing left
local armL = c:line({ {20+dx, 36+dy}, {13, 36+dy}, {13, 31+dy} }, 5)
local armR = c:line({ {45+dx, 35+dy}, {49+dx, 39+dy}, {43+dx, 44+dy} }, 5)
armL:cut(body:shrink(1)); armR:cut(body:shrink(1))
-- the lid: wooden rim with a 2 px side strip, picture inset
local lid = c:rrect(6, 9, 24, 30, 1)
local side = c:rect(7, 31, 23, 32)
local pic = c:rect(8, 11, 22, 28)
local handL = c:ellipse(13, 31+dy, 3, 3)
c:build{
  { "armL", armL, K.WIZ_ARM, { flat = true } },
  { "body", body, K.WIZ_BODY, { stitch = { side = "lit" } } },
  { "armR", armR, K.WIZ_ARM, { flat = true } },
  { "beard", beard, K.WIZ_BEARD, { gloss = { 26+dx, 41+dy-4 } } },
  { "hat", hat, K.WIZ_HAT, { gloss = { 29+dx, 10+dy-4 } } },
  { "side", side, GV.ramp("#8a4f2a"), { flat = true } },
  { "lid", lid, "wood", { gloss = false, cres = 2, deep = 1 } },
}
-- picture: sky bands, sun, two hills, little cottage
c:fill(pic, "#8fcbd8"); c:fill(c:rect(8, 11, 22, 13), "#7fc0de")
c:fill(c:ellipse(11, 29, 8, 7):clip(pic), "#7ab55c")
c:fill(c:ellipse(21, 30, 7, 6):clip(pic), "#94c46e")
c:fill(c:ellipse(19, 15, 1.5, 1.5), "#f5cf6a"); c:px(18, 14, "#fff1c8")
c:paint({ ".rrr.", "rrrrr", ".ccc.", ".cuc." }, 12, 18, { r = "#dd3a2a", c = "#f1ece0", u = "#4a2c1a" })
c:seam({ {7, 30}, {23, 30} })                                                 -- lid hem
c:part(handL, K.WIZ_ARM, { gloss = false, cres = 2, deep = 1 })
c:paint({ "u.u" }, 12, 29+dy, { u = "umber" })
c:paint({ "aa" }, 40+dx, 43+dy, { a = "#f08a24" })                            -- pointing finger
-- "look!" ticks off the lid
c:paint({ "g.", ".g" }, 26, 7, { g = "#f5cf6a" }); c:paint({ "gg" }, 27, 12, { g = "#f5cf6a" })
K.wizardFace(c, dx, dy-4)
K.save(c, "wizard-lid")
