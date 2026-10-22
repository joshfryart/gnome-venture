local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tan = GV.ramp("#b6814d")
local handle = c:ellipse(31.5, 14, 8, 7):cut(c:ellipse(31.5, 14, 4, 3.5)):cut(c:rect(0,15,63,63))
local p = c:build{
  { "handle", handle, GV.ramp("#c4925f"), { flat = true } },
  { "glass", c:rrect(22, 20, 41, 51, 5), "gold" },
  { "top", c:rrect(19, 14, 44, 21, 3), tan },
  { "bottom", c:rrect(19, 50, 44, 57, 3), tan },
}
c:fill(c:ellipse(31.5, 36, 6), "#e8a317")
c:fill(c:ellipse(31.5, 37, 3.5, 4), "#f08a24")
c:fill(c:ellipse(31.5, 38, 1.5, 2), "#d6322b")
c:px(29, 33, "#fff1c8"); c:px(30, 32, "#fff1c8")
c:seam({ {21, 22}, {42, 22} }); c:seam({ {21, 49}, {42, 49} })
local t = c:save(O .. "aseprite/ico/ico-lantern.aseprite", O .. "png/ico/ico-lantern.png")
print(GV.report(t))
