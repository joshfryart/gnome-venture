local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local body = c:ellipse(32, 28, 18, 18):cut(c:rect(0, 29, 63, 63))
body:add(c:rect(14, 28, 50, 47))
body:add(c:ellipse(19, 48, 5, 6))
body:add(c:ellipse(32, 49, 5.5, 6))
body:add(c:ellipse(45, 48, 5, 6))

c:build{
  { "body", body, GV.ramp("#f8eed2") },
}
local dark = "#2a1a10"
c:fill(c:ellipse(25, 29, 4, 5), dark)
c:fill(c:ellipse(39, 29, 4, 5), dark)
c:px(23, 26, "#f8eed2"); c:px(24, 26, "#f8eed2"); c:px(23, 27, "#f8eed2")
c:px(37, 26, "#f8eed2"); c:px(38, 26, "#f8eed2"); c:px(37, 27, "#f8eed2")
c:fill(c:ellipse(32, 39, 2.5, 3), dark)
c:px(31, 37, "#4a2c1a")

local t = c:save(O .. "aseprite/ico/ico-ghost.aseprite", O .. "png/ico/ico-ghost.png")
print(GV.report(t))
