local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local p = c:build{
  { "cover", c:rrect(14, 8, 50, 56, 4), GV.ramp("#3f93b2") },
  { "spine", c:rrect(14, 8, 19, 56, 2), GV.ramp("#256a80"), { flat = true, contour = false } },
  { "crest", c:ellipse(34, 24, 9), "gold" },
  { "bar1",  c:rrect(24, 38, 44, 41, 1), "gold", { flat = true } },
  { "bar2",  c:rrect(27, 44, 41, 47, 1), "gold", { flat = true } },
  { "stamp", c:ellipse(43, 48, 6.5), GV.ramp("#d6322b") },
}
-- globe lines on crest
local L = "#b07a10"
c:fill(c:line({ {26,24},{42,24} }, 1), L)
c:fill(c:line({ {34,16},{34,32} }, 1), L)
c:fill(c:line({ {31,17},{29,20},{29,28},{31,31} }, 1), L)
c:fill(c:line({ {37,17},{39,20},{39,28},{37,31} }, 1), L)
c:fill(c:line({ {28,19},{40,19} }, 1), L)
c:fill(c:line({ {28,29},{40,29} }, 1), L)
c:px(30, 20, "#fff1c8"); c:px(31, 19, "#fff1c8")
-- stamp inner ring
c:fill(c:ellipse(43, 48, 3.5):cut(c:ellipse(43, 48, 2)), "#f4f0e0")
-- seam beside spine
c:seam({ {21, 12}, {21, 52} })
local t = c:save(O .. "aseprite/ph/nav-passport.aseprite", O .. "png/ph/nav-passport.png")
print(GV.report(t))
