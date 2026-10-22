local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local handle = c:line({ {31, 21}, {46, 50} }, 6)
local head = c:poly({
  {9, 28}, {14, 22}, {20, 17}, {26, 14}, {32, 13}, {38, 14}, {44, 17}, {50, 22}, {55, 28},
  {49, 25}, {43, 22}, {37, 20}, {32, 20}, {27, 20}, {21, 22}, {15, 25},
})
local collar = c:rrect(27, 18, 37, 24, 1)
local knob = c:ellipse(46.5, 51.5, 4, 3.5)

local p = c:build{
  { "handle", handle, "wood" },
  { "knob", knob, GV.ramp("#a8582f") },
  { "head", head, GV.ramp("#c9c5bc", { shade = "#8b8f96" }), { gloss = { 21, 18 } } },
  { "collar", collar, GV.ramp("#8b8f96") },
}
c:seam({ {28, 21}, {36, 21} })
c:ground(36, 56, 15, 1)
local t = c:save(O .. "aseprite/ph/fine-rock-hammer.aseprite", O .. "png/ph/fine-rock-hammer.png")
print(GV.report(t))
