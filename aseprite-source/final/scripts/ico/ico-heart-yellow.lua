local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local m = c:rrect(10, 14, 32, 37, 8)
m:add(c:rrect(32, 14, 54, 37, 8))
m:add(c:poly({ {10, 32}, {55, 32}, {32.5, 52} }))
m:cut(c:poly({ {27, 13}, {39, 13}, {33, 22} }))
local r = GV.ramp("#e8c547", { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", shade = "#d0862a", deep = "#b8661a" })
c:part(m, r, { gloss = { 16, 19 } })
local t = c:save(O .. "aseprite/ico/ico-heart-yellow.aseprite", O .. "png/ico/ico-heart-yellow.png")
print(GV.report(t))
