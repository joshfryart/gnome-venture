local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
-- stretched hide: body plus scalloped top, four stubby leg flaps
local hide = c:rrect(16, 19, 47, 43, 6)
hide:add(c:ellipse(24, 18, 7, 4)):add(c:ellipse(39, 18, 7, 4))
hide:add(c:poly({ {17, 22}, {11, 21}, {10, 28}, {17, 31} }))
hide:add(c:poly({ {47, 22}, {53, 21}, {54, 28}, {47, 31} }))
hide:add(c:poly({ {17, 34}, {11, 38}, {13, 44}, {21, 41} }))
hide:add(c:poly({ {47, 34}, {53, 38}, {51, 44}, {43, 41} }))
hide = hide:closed(1)
-- long thin tail curling out the bottom right
local tail = c:line({ {36, 41}, {38, 47}, {42, 50}, {47, 51}, {51, 49}, {52, 46} }, 3)
local p = c:build{
  { "tail", tail, GV.ramp("#4a8a3e"), { cres = 1, deep = 0, gloss = false } },
  { "hide", hide, "moss", { stitch = true, gloss = { 22, 23 } } },
  { "head", c:ellipse(31.5, 14, 4, 3.5), GV.ramp("#6a9a3a") },
}
c:fill(c:rect(51, 45, 53, 47), "#2f5a2a")
-- spine seam
c:seam({ {32, 17}, {32, 43} })
-- fur tufts: short curved ticks
local tuft = { "t..", ".tt" }
c:paint(tuft, 22, 28, { t = "#4a8a3e" })
c:paint({ "..t", "tt." }, 37, 33, { t = "#4a8a3e" })
c:paint(tuft, 25, 38, { t = "#4a8a3e" })
c:paint({ "..t", "tt." }, 39, 23, { t = "#4a8a3e" })
local t = c:save(O .. "aseprite/ph/rat-pelt.aseprite", O .. "png/ph/rat-pelt.png")
print(GV.report(t))
