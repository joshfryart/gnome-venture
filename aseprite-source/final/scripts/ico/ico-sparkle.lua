local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local big = c:poly({ {26,17},{29,17},{31,32},{44,34},{44,37},{31,39},{29,53},{26,53},{24,39},{11,37},{11,34},{24,32} })
local small = c:poly({ {44,11},{47,11},{48,17},{53,18},{53,21},{48,22},{47,28},{44,28},{43,22},{37,21},{37,18},{43,17} })
big:add(c:poly({ {27.5,25},{38,35.5},{27.5,46},{17,35.5} }))
small:add(c:poly({ {45.5,14},{51,19.5},{45.5,25},{40,19.5} }))
c:build{
  { "big",   big,   "#f2b830", { gloss = { 25, 30 } } },
  { "small", small, "#dcb06a", { gloss = false } },
}
c:px(44, 17, "#fff1c8")
local t = c:save(O .. "aseprite/ico/ico-sparkle.aseprite", O .. "png/ico/ico-sparkle.png")
print(GV.report(t))
