local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- lumpy sack body: main ellipse plus side lumps
local sack = c:ellipse(31.5, 41, 19, 15)
sack:add(c:ellipse(18, 44, 6, 8)):add(c:ellipse(45, 44, 6, 8))
sack:add(c:poly({ {21, 30}, {43, 30}, {49, 38}, {15, 38} }))
local neck = c:poly({ {25, 22}, {39, 22}, {43, 31}, {21, 31} })
local tufts = c:poly({ {24, 14}, {28, 13}, {30, 23}, {25, 23} })
tufts:add(c:poly({ {36, 13}, {40, 14}, {39, 23}, {34, 23} }))
tufts:add(c:rect(29, 16, 35, 23))
local twine = c:rrect(21, 25, 43, 28, 1)
local knot = c:rrect(29, 24, 34, 30, 1)
local bean = c:poly({ {22, 38}, {26, 34}, {33, 33}, {40, 34}, {44, 38}, {44, 43}, {40, 47}, {34, 46}, {30, 48}, {25, 48}, {22, 45} })

local p = c:build{
  { "tufts", tufts, "#9a6b3f" },
  { "sack",  sack,  "#c9a96e" },
  { "neck",  neck,  "#c9a96e", { light = sack } },
  { "twine", twine, "#8a4f2a", { gloss = false } },
  { "knot",  knot,  "#8a4f2a", { gloss = false } },
  { "bean",  bean,  "#8c4a1a" },
}
-- fray lines on tufts
c:paint({ "w...w", ".w.w." }, 25, 15, { w = "#5e3a20" })
c:paint({ ".w.w.", "w...w" }, 35, 15, { w = "#5e3a20" })
-- twine knot loop ends
c:paint({ "t...t", ".t.t." }, 28, 31, { t = "#8a4f2a" })
-- bean hilum seam and dots
c:line({ {26, 41}, {30, 39}, {35, 38}, {41, 37} }, 1)
c:fill(c:line({ {26, 41}, {30, 39}, {35, 38}, {41, 37} }, 1), "#44281c")
c:fill(c:rect(27, 43, 29, 45), "#44281c")
c:fill(c:rect(32, 42, 34, 44), "#44281c")
c:fill(c:rect(37, 41, 39, 43), "#44281c")
-- burlap weave ticks
c:px(19, 40, "#9a6b3f"); c:px(19, 41, "#9a6b3f")
c:px(45, 41, "#9a6b3f"); c:px(45, 42, "#9a6b3f")
c:px(24, 51, "#9a6b3f"); c:px(25, 51, "#9a6b3f")
c:px(39, 51, "#9a6b3f"); c:px(40, 51, "#9a6b3f")
c:ground(31.5, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/fava-bean-seed.aseprite", O .. "png/ph/fava-bean-seed.png")
print(GV.report(t))
