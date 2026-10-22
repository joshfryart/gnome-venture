local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- upper shaft from the knob down to a jagged snapped end
local upper = c:line({ {44, 15}, {32, 37} }, 6)
upper:cut(c:poly({ {26, 35}, {30, 37}, {32, 33}, {34, 37}, {37, 35}, {38, 44}, {26, 44} }))
-- lower fragment, offset left, jagged top, thicker stub
local lower = c:line({ {27, 39}, {20, 52} }, 7)
lower:cut(c:poly({ {18, 34}, {23, 41}, {26, 38}, {28, 42}, {31, 39}, {33, 34} }))
local knob = c:ellipse(46, 11, 6.5, 6.5)
local chip = c:rect(46, 44, 49, 47)

c:build{
  { "lower", lower, GV.ramp("#c4925f") },
  { "upper", upper, GV.ramp("#b6814d") },
  { "knob", knob, GV.ramp("#8c4a1a"), { gloss = { 44, 8 } } },
  { "chip", chip, GV.ramp("#d9a660"), { flat = true } },
}
-- long zigzag crack along the upper shaft
c:fill(c:line({ {42, 19}, {38, 23}, {41, 25}, {37, 29}, {38, 31} }, 1):clip(upper:shrink(1)), "#2a1a10")
-- dark splintered faces at the break
c:fill(c:line({ {29, 34}, {30, 35}, {32, 32}, {34, 35}, {36, 33} }, 1):clip(upper), "#5e2f1e")
c:fill(c:line({ {20, 41}, {23, 43}, {26, 40}, {28, 44}, {30, 41} }, 1):clip(lower), "#ecc58a")
-- grain on the fragment
c:fill(c:line({ {24, 46}, {21, 51} }, 1), "#8a4f2a")
-- splinter ticks
c:fill(c:line({ {51, 47}, {52, 48} }, 1), "#d9a660")
c:fill(c:line({ {15, 38}, {13, 39} }, 1), "#d9a660")
c:ground(30, 54, 16, 2)
local t = c:save(O .. "aseprite/ph/broken-hiking-staff.aseprite", O .. "png/ph/broken-hiking-staff.png")
print(GV.report(t))
