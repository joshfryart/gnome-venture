local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bark = c:rrect(10, 23, 50, 49, 12)
bark:add(c:rect(30, 23, 48, 49))
local face = c:ellipse(47.5, 36, 9, 13)
local p = c:build{
  { "bark", bark, GV.ramp("#8c4a1a", { shade = "#6e3a1c" }), { gloss = { 18, 27 } } },
  { "knot", c:ellipse(24, 25, 2.5, 2), "#a8582f", { flat = true } },
  { "face", face, GV.ramp("#dcb06a"), { gloss = { 42, 27 } } },
}
-- bark grooves
c:fill(c:line({ { 16, 31 }, { 34, 31 } }, 2), "#5e2f1e")
c:fill(c:line({ { 15, 41 }, { 36, 41 } }, 2), "#5e2f1e")
c:fill(c:line({ { 22, 36 }, { 30, 36 } }, 2), "#5e2f1e")
-- growth ring
local ring = c:ellipse(47.5, 36, 5, 8):cut(c:ellipse(47.5, 36, 3, 6))
c:fill(ring, "#a5663a")
c:fill(c:rect(46, 35, 48, 37), "#b07a45")
c:ground(30.5, 51, 20, 2)
local t = c:save(O .. "aseprite/ico/ico-log.aseprite", O .. "png/ico/ico-log.png")
print(GV.report(t))
