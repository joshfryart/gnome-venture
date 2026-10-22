local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a8dcd0", { gloss = "#f0fbf6", rim = "#d8f2ea" })
local jar = c:rrect(13, 21, 51, 57, 8)
jar:add(c:rrect(22, 15, 42, 23, 2))
local fruit = c:ellipse(32, 40, 10.5, 10)
local leaf = c:poly({ {33, 30}, {37, 25}, {43, 23}, {41, 28}, {36, 31} })
local p = c:build{
  { "jar",   jar, glass, { gloss = { 17, 27 } } },
  { "cork",  c:rrect(21, 7, 43, 16, 3), "wood" },
  { "fruit", fruit, GV.ramp("#e8842a"), { gloss = { 26, 34 } } },
  { "leaf",  leaf, GV.ramp("#58a03e"), { flat = true } },
  { "label", c:rect(19, 50, 45, 53), GV.ramp("#dcb06a"), { flat = true } },
}
-- glass wall streaks
c:fill(c:rect(16, 30, 17, 46), "#f0fbf6")
c:fill(c:rect(16, 49, 17, 50), "#f0fbf6")
-- leaf stem
c:fill(c:rect(32, 28, 33, 31), "#2e5a2c")
-- cork grain
c:fill(c:rect(26, 10, 29, 10), "#a8582f"); c:fill(c:rect(34, 13, 37, 13), "#a8582f")
-- longan skin dots
c:px(36, 37, "#c8571e"); c:px(30, 45, "#c8571e"); c:px(37, 44, "#c8571e")
c:seam({ {23, 20}, {41, 20} })
local t = c:save(O .. "aseprite/ph/longan-seed.aseprite", O .. "png/ph/longan-seed.png")
print(GV.report(t))
