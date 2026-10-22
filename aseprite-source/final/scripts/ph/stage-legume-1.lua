local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local soil = GV.ramp("#8c4a1a")
local mound = c:ellipse(32, 47.5, 21, 8)
local p = c:build{
  { "mound", mound, soil },
  { "crown", c:ellipse(30, 45, 15, 4), "#a5663a", { light = mound, contact = false } },
  { "stem",  c:line({ {44, 46}, {44, 42}, {43, 38} }, 2), "moss", { flat = true } },
  { "leaf",  c:poly({ {44, 40}, {38, 36}, {33, 30}, {39, 30}, {43, 34}, {46, 39} }), "leaf" },
}
c:fill(c:ascii({ ".x", "xx" }, 44, 36), GV.R.leaf.base)
c:px(24, 43, "#6b3a18"); c:px(37, 48, "#6b3a18"); c:px(20, 48, "#6b3a18")
local t = c:save(O .. "aseprite/ph/stage-legume-1.aseprite", O .. "png/ph/stage-legume-1.png")
print(GV.report(t))
