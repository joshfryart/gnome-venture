local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- paper cone, leaning: wide mouth up, point at x 33
local cone  = c:poly({ {13, 22}, {50, 20}, {36, 57}, {31, 57} })
local twist = c:poly({ {22, 23}, {41, 22}, {46, 10}, {35, 15}, {29, 7}, {27, 15} })
local pepper = c:ellipse(32, 35, 7, 7)
local leaf = c:ellipse(39, 27, 3, 2)
local stem = c:rect(31, 26, 33, 29)

local paper = "#f1ece0"
c:build{
  { "twist", twist, "#dcb06a" },
  { "cone", cone, paper },
  { "pepper", pepper, "#d6322b" },
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { flat = true } },
}
-- twist creases
c:line({ {32, 16}, {32, 21} }, 1)
for y = 16, 21 do c:px(32, y, "#b8864a") end
for y = 12, 15 do c:px(29 + (15 - y) // 2, y, "#b8864a") end
-- fold crease on paper
c:seam({ {49, 22}, {36, 55} })
local t = c:save(O .. "aseprite/ph/chili-pepper-seed.aseprite", O .. "png/ph/chili-pepper-seed.png")
print(GV.report(t))
