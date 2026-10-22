local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- leaning runner, fitted inside ~12..51 so the icon halo clears the frame
local back = c:line({ {28, 39}, {22, 44}, {16, 46} }, 4)
back:add(c:rect(13, 44, 17, 48))
local front = c:line({ {29, 39}, {34, 44}, {36, 49} }, 4)
front:add(c:rect(35, 47, 41, 50))
local armB = c:line({ {28, 30}, {22, 33}, {18, 31} }, 3)
local armF = c:line({ {33, 29}, {41, 28}, {46, 23} }, 4)
local torso = c:ellipse(30.5, 33, 5, 7.5)
local head = c:ellipse(35.5, 22, 7, 6.5)
local hat = c:poly({ {28, 18}, {44, 18}, {41, 14}, {37, 10}, {35, 10} })
hat:add(c:rrect(27, 16, 45, 19, 1))

c:build{
  { "legB",  back,  "wood" },
  { "armB",  armB,  "skin" },
  { "legF",  front, "wood" },
  { "torso", torso, "red" },
  { "armF",  armF,  "skin" },
  { "head",  head,  "#f9d49c" },
  { "hat",   hat,   "#58a03e", { gloss = { 35, 13 } } },
}
c:eye(32, 22, true); c:eye(37, 22, true)
local t = c:save(O .. "aseprite/ico/ico-activity.aseprite", O .. "png/ico/ico-activity.png")
print(GV.report(t))
