local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local red = GV.ramp("#d6322b")
c:build{
  { "stemL", c:line({ {33, 14}, {28, 22}, {22, 32} }, 3), GV.ramp("#2e5a2c"), { flat = true } },
  { "stemR", c:line({ {34, 14}, {38, 24}, {41, 34} }, 3), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf", c:poly({ {34, 15}, {38, 11}, {44, 9}, {51, 10}, {47, 15}, {40, 17} }), GV.ramp("#58a03e") },
  { "left", c:ellipse(21.5, 40, 9.5, 9.5), red, { gloss = { 16, 35 } } },
  { "right", c:ellipse(42, 42, 9.5, 9.5), red, { gloss = { 37, 37 } } },
}
-- leaf vein
c:line({ {37, 14}, {48, 11} }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)

local t = c:save(O .. "aseprite/ico/ico-cherry.aseprite", O .. "png/ico/ico-cherry.png")
print(GV.report(t))
