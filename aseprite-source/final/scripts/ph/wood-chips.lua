local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(11, 19, 52, 55, 7)
body:add(c:ellipse(31.5, 37, 22, 15))
local lid = c:poly({ {16, 11}, {48, 11}, {53, 23}, {11, 23} })
local p = c:build{
  { "body", body, GV.ramp("#a5663a") },
  { "lid",  lid,  GV.ramp("#dcb06a") },
  { "knot", c:ellipse(31.5, 38, 11, 9), GV.ramp("#8c4a1a") },
}
-- inner knot ring
c:fill(c:ellipse(31.5, 38, 7, 5.5):cut(c:ellipse(31.5, 38, 5, 3.5)), "#6a3418")
-- V grain mark
c:fill(c:line({ {26, 34}, {31, 41}, {32, 41}, {37, 34} }, 2), "#44281c")
-- body grain strokes
c:fill(c:line({ {16, 30}, {16, 36} }, 2), "#8a4f2a")
c:fill(c:line({ {47, 42}, {47, 48} }, 2), "#8a4f2a")
c:fill(c:line({ {18, 46}, {20, 50} }, 2), "#8a4f2a")
-- lid grain
c:fill(c:line({ {22, 16}, {30, 16} }, 1), "#c09050")
c:fill(c:line({ {35, 19}, {44, 19} }, 1), "#c09050")
c:seam({ {12, 24}, {52, 24} })
c:ground(31.5, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/wood-chips.aseprite", O .. "png/ph/wood-chips.png")
print(GV.report(t))
