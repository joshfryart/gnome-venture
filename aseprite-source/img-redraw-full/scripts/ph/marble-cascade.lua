local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stone = GV.ramp("#968f96")
local jet = GV.ramp("#a9d6ea")
local water = GV.ramp("#3f93b2")
c:build{
  { "foot", c:rrect(20, 48, 43, 52, 2), stone },
  { "stem", c:rrect(26, 43, 37, 49, 1), stone },
  { "basin", c:ellipse(31.5, 37, 22, 9), stone, { gloss = { 14, 35 } } },
  { "water", c:ellipse(31.5, 35.5, 18, 5.5), water, { gloss = false } },
}
-- jet and arch (falling back into the pool)
c:part(c:rect(30, 18, 32, 36), jet, { flat = true })
c:part(c:line({ {24, 32}, {24, 25}, {26, 20}, {28, 17}, {31, 16}, {34, 17}, {36, 20}, {38, 25}, {38, 32} }, 3), jet, { flat = true, contour = false })
c:px(31, 17, "#c8ecdc"); c:px(30, 19, "#c8ecdc"); c:px(30, 22, "#c8ecdc"); c:px(25, 22, "#c8ecdc"); c:px(26, 20, "#c8ecdc")
-- ripples
for x = 16, 26 do c:px(x, 34, "#c8ecdc") end
for x = 35, 44 do c:px(x, 38, "#c8ecdc") end
for x = 19, 23 do c:px(x, 37, "#c8ecdc") end
-- splash rings where the arch lands
c:px(21, 33, "#c8ecdc"); c:px(27, 33, "#c8ecdc"); c:px(35, 33, "#c8ecdc"); c:px(41, 33, "#c8ecdc")
-- marble veins on the rim
c:paint({ "v.", ".v", ".v" }, 44, 30, { v = "#c9c5bc" })
c:paint({ ".v", "v.", }, 27, 44, { v = "#c9c5bc" })
c:paint({ "vv" }, 49, 40, { v = "#c9c5bc" })
local t = c:save(O .. "aseprite/ph/marble-cascade.aseprite", O .. "png/ph/marble-cascade.png")
print(GV.report(t))
