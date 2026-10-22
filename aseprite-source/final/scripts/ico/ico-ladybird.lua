local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local dark = GV.ramp("#35161f")
local ant = c:line({ {28,13}, {25,10}, {22,9}, {19,9} }, 2):add(c:rect(15,6,18,9))
ant:add(c:line({ {35,13}, {38,10}, {41,9}, {44,9} }, 2)):add(c:rect(45,6,48,9))
local p = c:build{
  { "ant", ant, dark, { flat = true } },
  { "shell", c:ellipse(31.5, 38, 20, 18.5), "red" },
  { "head", c:ellipse(31.5, 18, 8, 6.5), "dusk" },
}
c:fill(c:rect(31, 23, 32, 55):clip(p.shell.m), "#35161f")
c:spot(c:ellipse(22, 33, 4, 3.5)); c:spot(c:ellipse(41, 32, 4, 4))
c:spot(c:ellipse(22.5, 46, 3.5, 3)); c:spot(c:ellipse(41, 45, 3.5, 3.5))
c:spot(c:ellipse(31.5, 52, 2.5, 1.5))
c:eye(27, 16, true); c:eye(34, 16, true)
local t = c:save(O .. "aseprite/ico/ico-ladybird.aseprite", O .. "png/ico/ico-ladybird.png")
print(GV.report(t))
