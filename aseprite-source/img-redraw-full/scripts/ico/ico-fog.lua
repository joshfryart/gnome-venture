local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local r = GV.ramp("#9fb4bf", { gloss = "#fff3c8" })
c:build{
  { "b1", c:rrect(18, 11, 44, 17, 3), r },
  { "b2", c:rrect(10, 22, 40, 28, 3), r },
  { "b3", c:rrect(22, 33, 51, 39, 3), r },
  { "b4", c:rrect(12, 44, 44, 50, 3), r },
}
local t = c:save(O .. "aseprite/ico/ico-fog.aseprite", O .. "png/ico/ico-fog.png")
print(GV.report(t))
