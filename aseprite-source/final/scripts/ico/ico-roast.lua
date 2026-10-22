local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bone = GV.ramp("#f1ece0")
-- bone shaft + two knuckles (drawn first, meat overlaps)
local shaft = c:line({ {15, 45}, {30, 33} }, 6)
local knobs = c:ellipse(11, 43, 5, 5):add(c:ellipse(17, 51, 5, 5))
c:build{
  { "knobs", knobs, bone },
  { "shaft", shaft, bone, { gloss = false } },
}
local meat = c:ellipse(39, 26, 17, 14):add(c:ellipse(30, 32, 7, 6))
local glaze = c:poly({ {30, 18}, {38, 15}, {47, 17}, {50, 23}, {46, 30}, {40, 28}, {34, 31}, {29, 26} })
c:build{
  { "meat", meat, GV.ramp("#a5663a") },
  { "glaze", glaze, GV.ramp("#6a4528"), { contact = false, gloss = { 33, 19 } } },
}
-- char marks
c:paint({ "cc.", ".cc" }, 50, 27, { c = "#5e2f1e" })
c:paint({ "cc.", ".cc" }, 42, 34, { c = "#5e2f1e" })
local t = c:save(O .. "aseprite/ico/ico-roast.aseprite", O .. "png/ico/ico-roast.png")
print(GV.report(t))
