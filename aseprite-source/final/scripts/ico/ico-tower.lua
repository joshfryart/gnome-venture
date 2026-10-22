local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local pale = GV.ramp("#c9c5bc")
local mer = c:rect(11, 7, 20, 18):add(c:rect(27, 7, 36, 18)):add(c:rect(43, 7, 52, 18))
local door = c:rect(28, 51, 36, 57):add(c:ellipse(32, 51, 4, 4))
c:build{
  { "shaft", c:rect(19, 25, 45, 57), "stone" },
  { "merlons", mer, pale },
  { "band", c:rect(11, 17, 52, 26), pale, { light = c:rect(11, 7, 52, 57) } },
  { "door", door, GV.ramp("#8a4f2a", { base = "#5e2f1e" }), { gloss = false } },
}
local win = c:rect(30, 33, 34, 40):add(c:rect(31, 32, 33, 32))
c:fill(win, "#3a3a44")
c:fill(c:rect(31, 34, 31, 36), "#5b6470")
c:fill(c:rect(19, 30, 45, 30), "#5b6470"); c:fill(c:rect(32, 27, 32, 29), "#5b6470")
c:fill(c:rect(19, 43, 27, 43), "#5b6470"); c:fill(c:rect(37, 43, 45, 43), "#5b6470")
c:fill(c:rect(25, 31, 25, 42), "#5b6470"); c:fill(c:rect(40, 31, 40, 42), "#5b6470")
c:fill(c:rect(32, 47, 32, 47), "#5b6470")
c:fill(c:rect(32, 49, 32, 57), "#2a1a10")
c:px(30, 54, "#e8a317"); c:px(34, 54, "#e8a317")
local t = c:save(O .. "aseprite/ico/ico-tower.aseprite", O .. "png/ico/ico-tower.png")
print(GV.report(t))
