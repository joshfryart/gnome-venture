local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 32, h = 40, mode = "sticker" }
local R = GV.R.water
-- teardrop: round belly + tapered point (tip 3 px wide at its base)
local body = c:ellipse(15.5, 23.5, 6.5, 6.5)
body:add(c:poly({ {14, 8}, {18, 8}, {22, 21}, {9, 21} }))
body:add(c:poly({ {14, 8}, {18, 8}, {20, 14}, {11, 14} }))
c:build{
  { "drop", body, "water", { gloss = false } },
}
-- long curved gloss streak down the left side, plus a tiny second dot
c:paint({
  "..g",
  ".gg",
  ".g.",
  "gg.",
  "g..",
  "g..",
  "g..",
  "gg.",
  ".g.",
}, 11, 16, { g = R.gloss })
c:px(14, 13, R.dot or R.gloss)
c:px(13, 26, R.gloss)
local t = c:save(O .. "aseprite/gather/calm-drop.aseprite", O .. "png/gather/calm-drop.png")
print(GV.report(t))
