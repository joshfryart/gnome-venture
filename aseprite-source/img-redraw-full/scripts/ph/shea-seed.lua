local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy pear sack
local body = c:ellipse(32, 44, 19, 12)
body:add(c:ellipse(32, 36, 13, 10))
body:add(c:rrect(15, 46, 49, 56, 5))
body:cut(c:rect(0, 57, 63, 63))
-- neck + flared notched tuft
local neck = c:poly({ {26, 18}, {38, 18}, {41, 28}, {23, 28} })
local tuft = c:poly({ {22, 9}, {42, 9}, {38, 19}, {26, 19} })
tuft:cut(c:poly({ {27, 9}, {29, 9}, {28, 13} }))
tuft:cut(c:poly({ {31, 9}, {34, 9}, {32, 13} }))
tuft:cut(c:poly({ {36, 9}, {38, 9}, {37, 13} }))
neck:add(tuft)
local p = c:build{
  { "sack", body, "#c9a96e", { stitch = { side = "lit" } } },
  { "neck", neck, "#c9a96e" },
  { "twine", c:rrect(22, 23, 42, 26, 1), "#8c4a1a" },
  { "patch", c:rrect(20, 32, 44, 52, 5), "#f4f0e0", { pale = true } },
  { "nut", c:ellipse(32, 43, 8, 8), "#3f93b2" },
  { "cap", c:ellipse(32, 37, 7, 3):clip(c:ellipse(32, 43, 8, 8)), "#256a80", { flat = true } },
  { "sprout", c:line({ {32, 34}, {32, 29} }, 3), "#2e5a2c", { flat = true } },
}
c:paint({ "ll..", "llll", ".ll." }, 34, 28, { l = "#58a03e" })
c:px(26, 54, "#8c4a1a"); c:px(38, 54, "#8c4a1a"); c:px(20, 50, "#8c4a1a"); c:px(44, 50, "#8c4a1a")
c:seam({ {19, 55}, {45, 55} })
c:button(42, 23)
local t = c:save(O .. "aseprite/ph/shea-seed.aseprite", O .. "png/ph/shea-seed.png")
print(GV.report(t))
