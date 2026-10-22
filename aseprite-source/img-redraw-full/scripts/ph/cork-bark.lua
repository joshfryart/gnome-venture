local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tube = c:rrect(6, 24, 57, 48, 12)
local face = c:ellipse(48.5, 36, 8.5, 12)
c:build{
  { "tube", tube, GV.ramp("#8c4a1a"), { gloss = { 14, 28 } } },
  { "face", face, GV.ramp("#dcb06a"), { gloss = false } },
}
-- growth ring
local ring = c:ellipse(48.5, 36, 5, 7):cut(c:ellipse(48.5, 36, 3, 5))
c:fill(ring, "#a5663a")
c:fill(c:ellipse(48.5, 36, 1, 2), "#a5663a")
-- grooves (unequal)
c:line({ {14, 31}, {33, 31} }, 2)
c:fill(c:line({ {14, 31}, {33, 31} }, 2), "#5e2f1e")
c:fill(c:line({ {12, 40}, {36, 40} }, 2), "#5e2f1e")
c:fill(c:line({ {20, 35}, {28, 35} }, 2), "#6e3a1e")
-- nubbly flecks along lower edge
for _, x in ipairs({ 15, 25, 35 }) do c:fill(c:rect(x, 44, x + 1, 45), "#5e2f1e") end
c:ground(32, 51, 22, 1.5)
local t = c:save(O .. "aseprite/ph/cork-bark.aseprite", O .. "png/ph/cork-bark.png")
print(GV.report(t))
