local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plinth = c:poly({ {18,41}, {47,41}, {50,56}, {14,56} })
plinth:cut(c:rect(45, 52, 50, 56)); plinth:cut(c:rect(47, 50, 50, 51))
local lip = c:rrect(16, 38, 48, 42, 1)
local head = c:ellipse(32, 27, 13, 13)
local hat = c:poly({ {19,21}, {45,21}, {38,9}, {35,4}, {33,5}, {27,12} })
hat:add(c:rrect(18, 18, 46, 22, 2))
local beard = c:poly({ {21,31}, {44,31}, {39,40}, {33,47}, {31,47}, {25,40} })
local p = c:build{
  { "plinth", plinth, "#8b8f96" },
  { "lip", lip, "#c9c5bc" },
  { "head", head, "#d6c9b6" },
  { "beard", beard, "#e2d8c6" },
  { "hat", hat, "#5b6470" },
  { "nose", c:ellipse(32.5, 30.5, 2.5, 2), "#c9c5bc", { flat = true } },
}
c:seam({ {18, 40}, {46, 40} })
c:eye(23, 23); c:eye(36, 23)
c:spot(c:ellipse(19, 50, 2.5, 1.5), "#6a9a3a", "#a4b86a")
c:spot(c:ellipse(23, 51, 1.5, 1), "#6a9a3a", "#a4b86a")
c:paint({ "w.w", ".w." }, 29, 41, { w = "#b8ad9a" })
c:ground(32, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/gnome-statue.aseprite", O .. "png/ph/gnome-statue.png")
print(GV.report(t))
