local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local disc = c:ellipse(31.5, 31.5, 25)
c:build{
  { "disc", disc, "gold" },
}
c:stitch(c:ellipse(31.5, 31.5, 23), { side = "lit" })
c:build{
  { "north", c:poly({ {32, 9}, {43, 33}, {21, 33} }):add(c:rect(31, 9, 32, 12)), "red", { light = c:ellipse(31.5, 31.5, 12, 23) } },
  { "south", c:poly({ {21, 31}, {43, 31}, {32, 55} }), "cream", { light = c:ellipse(31.5, 31.5, 12, 23) } },
}
c:fill(c:rrect(30, 30, 33, 33, 1), "#7a3a14")
c:px(31, 31, "#d0862a")
local t = c:save(O .. "aseprite/ico/ico-compass.aseprite", O .. "png/ico/ico-compass.png")
print(GV.report(t))
