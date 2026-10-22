local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(32, 42, 16, 13):add(c:ellipse(32, 25, 9, 11))
fruit:add(c:poly({ {23, 25}, {41, 25}, {47, 38}, {17, 38} }))
local p = c:build{
  { "stem", c:rect(31, 9, 33, 17), "#2f5a2a", { flat = true } },
  { "leaf", c:poly({ {34, 12}, {38, 7}, {43, 5}, {41, 10}, {36, 13} }), "moss", { flat = true } },
  { "fruit", fruit, "#f08a24" },
  { "window", c:ellipse(32, 40, 6, 8), "#f9d49c", { gloss = false, pale = true } },
}
c:paint({ "ss", "ss" }, 30, 35, { s = "#35161f" }); c:px(30, 35, "#5e2a3a")
c:paint({ "ss", "ss" }, 33, 38, { s = "#35161f" }); c:px(33, 38, "#5e2a3a")
c:paint({ "ss", "ss" }, 29, 41, { s = "#35161f" }); c:px(29, 41, "#5e2a3a")
c:paint({ "ss", "ss" }, 33, 43, { s = "#35161f" }); c:px(33, 43, "#5e2a3a")
local t = c:save(O .. "aseprite/ph/papaya.aseprite", O .. "png/ph/papaya.png")
print(GV.report(t))
