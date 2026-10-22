local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- kiwi fruit peeks out of the open top of a tall narrow envelope
local leaf = c:poly({ {33,8}, {38,4}, {44,5}, {41,10}, {35,12} })
local kiwi = c:ellipse(31.5, 17, 9, 8)
local env  = c:rrect(18, 18, 45, 57, 2)
local flap = c:poly({ {18,22}, {46,22}, {32,40} })

local p = c:build{
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
  { "kiwi", kiwi, GV.ramp("#a5663a") },
  { "env",  env,  GV.ramp("#f4f0e0"), { stitch = true } },
  { "flap", flap, GV.ramp("#dcb06a"), { light = env } },
}
-- leaf vein, kiwi fuzz specks
c:fill(c:line({ {35,10}, {41,6} }, 1), "#3a7a2e")
c:paint({ "f...f", "..f..", "f...." }, 26, 12, { f = "#7a4424" })
-- flap edge line
c:fill(c:line({ {18,22}, {32,37} }, 2), "#a5663a")
c:fill(c:line({ {45,22}, {32,37} }, 2), "#a5663a")
c:seam({ {21,26}, {30,36} }); c:seam({ {43,26}, {34,36} })
c:button(30, 36)
-- lower label
local lab = c:rrect(24, 44, 40, 53, 2)
c:part(lab, "cream", { gloss = false, contact = false })
c:fill(c:ellipse(32, 48.5, 2.5, 2.5), "#8c4a1a")
c:px(31, 47, "#c47a52")
-- corner crease
c:fill(c:line({ {20,55}, {24,51} }, 2), "#dcb06a")
local t = c:save(O .. "aseprite/ph/kiwi-seed.aseprite", O .. "png/ph/kiwi-seed.png")
print(GV.report(t))
