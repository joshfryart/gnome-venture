local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local drop = c:ellipse(31.5, 40, 18, 16)
drop:add(c:poly({ {30, 9}, {34, 9}, {49, 37}, {14, 37} }))
c:build{ { "drop", drop, GV.ramp("#3f93b2", { rim = "#8fcbd8", gloss = "#c8ecdc", shade = "#2f6290", deep = "#2a3c6c" }), { cres = 5, gloss = false } } }
c:fill(c:line({ {22, 34}, {22, 40}, {24, 45} }, 3), "#c8ecdc")
c:fill(c:rect(23, 27, 25, 29), "#c8ecdc")
local t = c:save(O .. "aseprite/ico/ico-droplet.aseprite", O .. "png/ico/ico-droplet.png")
print(GV.report(t))
