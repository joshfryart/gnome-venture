local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local box = c:rrect(12, 20, 44, 44, 3)
box:add(c:ellipse(28, 26, 16, 10):cut(c:rect(0, 27, 63, 63)))
box:cut(c:rect(0, 0, 11, 63))
local p = c:build{
  { "post", c:rect(25, 43, 31, 52), GV.ramp("#c4925f") },
  { "box", box, "red" },
  { "pole", c:rect(45, 15, 48, 40), "gold" },
  { "flag", c:rect(37, 13, 48, 19), GV.ramp("#f5cf6a"), { gloss = { 39, 15 } } },
}
c:fill(c:rrect(18, 28, 36, 32, 1), "#2a1a10")
c:fill(c:rect(19, 29, 35, 29), "#4a2c1a")
c:seam({ {15, 37}, {41, 37} })
c:paint({ ".h.", "hhh", ".h." }, 45, 34, { h = "#7a3a14" })
c:ground(28, 53, 11, 1.5)
local t = c:save(O .. "aseprite/ico/ico-mailbox.aseprite", O .. "png/ico/ico-mailbox.png")
print(GV.report(t))
