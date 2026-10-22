local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local ticks = c:rect(37, 13, 46, 15):add(c:rect(37, 21, 43, 23)):add(c:rect(37, 29, 46, 31))
local p = c:build{
  { "ticks", ticks, "#8b8f96", { flat = true } },
  { "stem", c:rrect(21, 7, 35, 46, 7), GV.ramp("#f8eed2"), { gloss = { 24, 12 } } },
  { "bulb", c:ellipse(28.5, 46, 12, 11.5), "red" },
  { "merc", c:rrect(26, 20, 31, 40, 3), "red", { flat = true, contact = false } },
}
c:save(O .. "aseprite/ico/ico-thermometer.aseprite", O .. "png/ico/ico-thermometer.png")
print(GV.report(c:check()))
