local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local chim = c:rect(39, 14, 44, 26)
local walls = c:rect(15, 30, 48, 51)
local roofL = c:poly({ {11, 34}, {32, 13}, {32, 34} })
local roofR = c:poly({ {32, 13}, {53, 34}, {32, 34} })
c:build{
  { "chimney", chim, GV.ramp("#c4925f") },
  { "walls", walls, "#f1ece0" },
  { "roofL", roofL, GV.ramp("#e0501f") },
  { "roofR", roofR, GV.ramp("#d6322b"), { gloss = false } },
  { "door", c:rrect(27, 39, 36, 51, 2), GV.ramp("#8c4a1a") },
  { "winL", c:rect(18, 37, 23, 42), GV.ramp("#a9d6ea"), { flat = true } },
  { "winR", c:rect(40, 37, 45, 42), GV.ramp("#a9d6ea"), { flat = true } },
}
c:fill(c:rect(33, 45, 34, 46), "#e8a317")
c:seam({ {13, 32}, {50, 32} })
c:button(30, 18)
local t = c:save(O .. "aseprite/ph/nav-today.aseprite", O .. "png/ph/nav-today.png")
print(GV.report(t))
