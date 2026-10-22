local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local dark = GV.ramp("#4a8a3e")
local light = "moss"
local ant = c:line({ {41, 22}, {39, 17}, {36, 13} }, 3)
ant:add(c:line({ {50, 22}, {52, 17}, {54, 13} }, 3))
local p = c:build{
  { "ant", ant, "#2f5a2a", { flat = true } },
  { "clubL", c:rrect(33, 9, 37, 13, 1), "#2f5a2a", { flat = true } },
  { "clubR", c:rrect(53, 9, 57, 13, 1), "#2f5a2a", { flat = true } },
  { "rear", c:ellipse(12, 44, 7, 7), dark },
  { "mid", c:ellipse(22, 45, 7, 7), light },
  { "third", c:ellipse(32, 44, 7, 7), dark },
  { "neck", c:ellipse(41, 40, 8, 8), light },
  { "head", c:ellipse(46, 28, 11, 10), light },
}
c:eye(39, 24); c:eye(49, 24)
c:paint({ "u...u", ".uuu." }, 43, 32, { u = "umber" })
local t = c:save(O .. "aseprite/ico/ico-caterpillar.aseprite", O .. "png/ico/ico-caterpillar.png")
print(GV.report(t))
