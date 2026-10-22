local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local moss = GV.ramp("#58a03e", { gloss = "#c8d77a", dot = "#fff1c8", rim = "#a4b86a",
  shade = "#4a8a3e", deep = "#2f5a2a", bounce = "#6a9a3a" })
local heart = c:ellipse(21.5, 24, 11.5, 11):add(c:ellipse(42.5, 24, 11.5, 11))
heart:add(c:poly({ {11, 27}, {53, 27}, {33, 52}, {31, 52} }))
heart:add(c:poly({ {10, 24}, {54, 24}, {54, 30}, {10, 30} }):clip(c:ellipse(32, 26, 23, 12)))
-- deep centred notch
heart:cut(c:poly({ {27, 11}, {37, 11}, {32, 21} }))
heart = heart:closed(1)
c:part(heart, moss, { gloss = { 17, 18 } })
local t = c:save(O .. "aseprite/ico/ico-heart-green.aseprite", O .. "png/ico/ico-heart-green.png")
print(GV.report(t))
