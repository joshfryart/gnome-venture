local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(32, 37, 18, 17)
local stalk = c:rect(31, 13, 33, 22)
local leaf = c:poly({ {33, 18}, {36, 11}, {43, 6}, {47, 5}, {45, 10}, {40, 16} })
local p = c:build{
  { "stalk", stalk, GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
  { "fruit", fruit, "gold" },
}
c:paint({
  "...c...",
  "...c...",
  "..ccc..",
  "ccccccc",
  "..ccc..",
  "...c...",
  "...c...",
}, 29, 44, { c = "#7a3a14" })
c:px(32, 47, "#b8661a")
c:px(25, 33, "#d0862a"); c:px(39, 29, "#d0862a"); c:px(41, 41, "#d0862a"); c:px(23, 41, "#d0862a")
c:line({ {36, 15}, {43, 8} }, 1)
local t = c:save(O .. "aseprite/ph/feijoa.aseprite", O .. "png/ph/feijoa.png")
print(GV.report(t))
