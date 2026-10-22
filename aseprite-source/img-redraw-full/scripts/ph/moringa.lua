local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local blade = c:ellipse(32, 38, 19, 15)
blade:add(c:poly({ {32, 9}, {33, 9}, {51, 34}, {13, 34} }))
local stalk = c:rect(31, 50, 33, 57)
c:build{
  { "stalk", stalk, GV.ramp("#4a8a3e"), { flat = true } },
  { "blade", blade, "moss", { gloss = { 22, 26 } } },
}
local rib = c:line({ {32, 15}, {32, 51} }, 2)
c:fill(c:line({ {32, 40}, {21, 31} }, 2):clip(blade), "#4a8a3e")
c:fill(c:line({ {33, 31}, {43, 22} }, 2):clip(blade), "#4a8a3e")
c:fill(c:line({ {33, 45}, {44, 37} }, 2):clip(blade), "#4a8a3e")
c:fill(c:line({ {32, 47}, {23, 41} }, 2):clip(blade), "#4a8a3e")
c:fill(rib, "#2f5a2a")
local t = c:save(O .. "aseprite/ph/moringa.aseprite", O .. "png/ph/moringa.png")
print(GV.report(t))
