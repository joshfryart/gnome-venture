local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "lwall", c:rect(10, 34, 29, 52), "#dcb06a" },
  { "lroof", c:poly({ {8, 36}, {19, 23}, {32, 36} }), "#d6322b" },
  { "rwall", c:rect(31, 29, 52, 52), "#f1ece0" },
  { "rroof", c:poly({ {28, 30}, {41.5, 13}, {56, 30} }), "#7a5cc0" },
  { "ldoor", c:rect(16, 43, 21, 52), "#b6814d", { gloss = false } },
  { "rdoor", c:rect(38, 41, 45, 52), "#8c4a1a", { gloss = false } },
}
local win = GV.ramp("#a9d6ea")
c:part(c:rect(12, 38, 15, 41), win, { flat = true })
c:part(c:rect(33, 34, 37, 38), win, { flat = true })
c:part(c:rect(47, 34, 51, 38), win, { flat = true })
c:px(43, 47, "#e8a317")  -- door knob
c:button(40, 20)
c:ground(31.5, 53, 22, 1.5)
local t = c:save(O .. "aseprite/ph/nav-town.aseprite", O .. "png/ph/nav-town.png")
print(GV.report(t))
