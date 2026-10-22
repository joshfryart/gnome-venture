local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood = GV.ramp("#b6814d", { rim = "#f0d49a" })
local shaft = c:line({ {25, 52}, {45, 13} }, 6)
-- jagged snap across the middle
local zig = { {28, 29}, {31, 32}, {33, 28}, {36, 33}, {38, 29}, {41, 34}, {44, 32} }
local gap = c:line(zig, 3)
local lowZone = c:poly({ {28, 29}, {31, 32}, {33, 28}, {36, 33}, {38, 29}, {41, 34}, {44, 32},
  {63, 36}, {63, 63}, {0, 63}, {0, 26} })
local lower = shaft:copy():clip(lowZone):cut(gap)
local upper = shaft:copy():cut(lowZone):cut(gap):shift(1, -1)
local branch = c:line({ {29, 42}, {22, 45} }, 5)
local knob = c:ellipse(46.5, 11.5, 5.5, 5.5)

c:build{
  { "branch", branch, GV.ramp("#c4925f") },
  { "lower", lower, wood, { light = shaft } },
  { "upper", upper, wood, { light = shaft } },
  { "knob", knob, GV.ramp("#8c4a1a"), { gloss = { 43, 8 } } },
  { "chipA", c:line({ {48, 40}, {51, 44} }, 3), GV.ramp("#c4925f"), { flat = true } },
  { "chipB", c:line({ {17, 33}, {13, 36} }, 3), GV.ramp("#c4925f"), { flat = true } },
}
-- wood grain flecks
c:px(30, 46, wood.shade); c:px(31, 44, wood.shade)
c:px(40, 20, wood.shade); c:px(39, 22, wood.shade)

local t = c:save(O .. "aseprite/ph/broken-wayfarer-s-staff.aseprite", O .. "png/ph/broken-wayfarer-s-staff.png")
print(GV.report(t))
