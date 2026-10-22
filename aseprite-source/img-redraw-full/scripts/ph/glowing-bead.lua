local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bead = c:ellipse(32, 34, 16, 16)
local p = c:build{ { "bead", bead, GV.ramp("#f4f0e0"), { gloss = { 23, 25 } } } }
-- inner glow rings (stay inside the body)
c:fill(c:ellipse(33, 36, 9, 9), "#f5cf6a")
c:fill(c:ellipse(33, 36, 6, 6):cut(c:ellipse(32, 35, 5, 5)), "#e8a317")
c:fill(c:ellipse(32, 35, 5, 5), "#ffe08a")
c:fill(c:ellipse(33, 36, 3, 3), "#e8a317")
c:px(31, 34, "#fff1c8")
-- threading hole at the top
c:paint({ ".h.", "hhh", ".h." }, 31, 20, { h = "#8a4a1c" })
local t = c:save(O .. "aseprite/ph/glowing-bead.aseprite", O .. "png/ph/glowing-bead.png")
print(GV.report(t))
