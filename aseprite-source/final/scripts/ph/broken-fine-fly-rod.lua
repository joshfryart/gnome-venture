local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- rod along (10,56)->(50,10), snapped at about (31,32)
local rod = c:line({ {14, 52}, {50, 11} }, 4)
local gap = c:line({ {26, 26}, {30, 29}, {29, 31}, {33, 33}, {32, 35}, {36, 38} }, 3)
rod:cut(gap)
local lower, upper = c:mask(), c:mask()
rod:each(function(x, y)
  if 36 * (x - 31) - 41 * (y - 32) > 0 then upper:set(x, y) else lower:set(x, y) end
end)
upper = upper:shift(2, -1)
local grip = c:line({ {13, 54}, {21, 44} }, 6)
local reel = c:ellipse(21, 43, 5.5)
local line = c:line({ {51, 11}, {54, 15}, {55, 21}, {53, 27}, {50, 31} }, 2)
local knob = c:ellipse(49, 34, 3)
local splinter = c:line({ {39, 41}, {42, 44} }, 2)
local p = c:build{
  { "line", line, "stone", { flat = true } },
  { "knob", knob, "stone", { gloss = false } },
  { "upper", upper, GV.ramp("#b6814d"), { gloss = false } },
  { "lower", lower, GV.ramp("#b6814d"), { gloss = false } },
  { "grip", grip, "cream", { gloss = false } },
  { "reel", reel, GV.ramp("#8b8f96") },
  { "splinter", splinter, GV.ramp("#b6814d"), { flat = true } },
}
c:fill(c:ellipse(21, 43, 1.5), "#5b6470")
c:fill(c:line({ {15, 51}, {16, 50} }, 1), "#c9a96e")
local t = c:save(O .. "aseprite/ph/broken-fine-fly-rod.aseprite", O .. "png/ph/broken-fine-fly-rod.png")
print(GV.report(t))
