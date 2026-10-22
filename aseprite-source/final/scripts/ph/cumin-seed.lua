local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local sack = c:ellipse(32, 41, 18, 15)
sack:add(c:rrect(15, 44, 49, 56, 6))
local neck = c:rrect(26, 19, 38, 29, 3)
local ruffle = c:poly({ {21, 19}, {23, 11}, {27, 15}, {32, 8}, {37, 15}, {41, 11}, {43, 19} })
ruffle:add(c:rrect(23, 15, 41, 20, 2))
local twine = c:rrect(24, 22, 40, 25, 1)
local bowL = c:ellipse(20.5, 23.5, 3, 2.5)
local bowR = c:ellipse(43.5, 23.5, 3, 2.5)
-- curved cumin seed patch: crescent
local patch = c:ellipse(32, 40, 11, 6):cut(c:ellipse(33, 35, 11, 5))
patch:add(c:line({ {22, 41}, {27, 44}, {35, 44}, {42, 39} }, 3))
local sprig = c:rect(18, 42, 21, 45)

local p = c:build{
  { "sack",   sack,   GV.ramp("#c9a96e"), { stitch = { side = "lit" } } },
  { "neck",   neck,   GV.ramp("#c9a96e"), { flat = true } },
  { "ruffle", ruffle, GV.ramp("#9a6b3f") },
  { "twine",  twine,  GV.ramp("#8c4a1a"), { flat = true } },
  { "bowL",   bowL,   GV.ramp("#8c4a1a"), { flat = true } },
  { "bowR",   bowR,   GV.ramp("#8c4a1a"), { flat = true } },
  { "patch",  patch,  GV.ramp("#a5663a"), { flat = true } },
  { "sprig",  sprig,  GV.ramp("#2e5a2c"), { flat = true } },
}
-- seed ridges
c:px(27, 43, "#8c4a1a"); c:px(32, 44, "#8c4a1a"); c:px(37, 42, "#8c4a1a")
-- bow knot centre holes
c:px(20, 23, "#5e2f1e"); c:px(44, 23, "#5e2f1e")
-- burlap weave hints
c:px(40, 31, "#a8875a"); c:px(44, 36, "#a8875a"); c:px(41, 50, "#a8875a"); c:px(28, 52, "#a8875a")
c:seam({ {23, 32}, {23, 52} })
c:ground(32, 57, 17, 1.5)
local t = c:save(O .. "aseprite/ph/cumin-seed.aseprite", O .. "png/ph/cumin-seed.png")
print(GV.report(t))
