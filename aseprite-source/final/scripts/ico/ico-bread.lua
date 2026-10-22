local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local base = c:ellipse(31.5, 38, 24, 16)
local crown = c:ellipse(30.5, 32, 20, 12.5)
local s1 = c:line({ {23, 24}, {27, 38} }, 4)
local s2 = c:line({ {36, 24}, {40, 38} }, 4)
local p = c:build{
  { "base", base, GV.ramp("#a5663a", { deep = "#5e2f1e" }), { light = base } },
  { "crown", crown, GV.ramp("#dcb06a"), { gloss = { 16, 27 } } },
  { "s1", s1, GV.ramp("#f0d49a"), { flat = true, contour = false } },
  { "s2", s2, GV.ramp("#f0d49a"), { flat = true, contour = false } },
}
c:fill(c:line({ {25, 26}, {28, 37} }, 2):clip(s1), "#a27e55")
c:fill(c:line({ {38, 26}, {41, 37} }, 2):clip(s2), "#a27e55")
local t = c:save(O .. "aseprite/ico/ico-bread.aseprite", O .. "png/ico/ico-bread.png")
print(GV.report(t))
